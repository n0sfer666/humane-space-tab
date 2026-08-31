# S00 — Threat model

**Status:** agreed · **Depends on:** — · **ADRs:** [0001](../adr/0001-foundation.md)

## Goal

Define what `humane-space-tab` is allowed to do, what it must never be able to do,
and which of those limits are enforced by a machine rather than by a promise. Every
later spec inherits these boundaries; a spec that needs to cross one has to amend
this document first.

The app requires the macOS **Accessibility** permission and cannot work without it.
That permission is the most powerful one a user can grant, so the security posture
here is not "we are careful" — it is "the app is structurally incapable of most of
what the permission would allow".

## Non-goals

Explicitly outside the threat model. Attacks in these classes are not defended
against, because a defence would be theatre:

- an attacker with root or physical access to the machine;
- another application that has already been granted Accessibility by the user;
- a compromised macOS, compromised Xcode toolchain, or compromised GitHub;
- the user deliberately granting the app permissions it does not ask for.

Inside the model: everything an attacker could do **through** this application —
using it as a proxy to Accessibility, extracting user data from it, tampering with
its released artefacts, or landing malicious code in it through a pull request.

## Design

### Assets

1. Keyboard events flowing through the event tap — every keystroke of every app.
2. The list of running applications and their window metadata.
3. The Accessibility grant itself, as a capability that other code could borrow.
4. Released artefacts, as a distribution channel into users' machines.

### Permissions

| Permission | Requested | Rationale |
|---|---|---|
| Accessibility | yes, required | `CGEventTap` interception and raising other apps' windows |
| Input Monitoring | **never** | the tap works without a grant here; a row that *denies* it silently strips key presses from the tap, which S15 detects and explains |
| Screen Recording | **never** | only needed for window previews and `kCGWindowName`; both are out of scope |
| Full Disk Access, Camera, Microphone, Contacts, … | never | no use case exists |

Window previews are not implemented, in any release, in any settings combination.
Removing that feature removes an entire TCC domain from the model. The switcher
shows application icons and application names only.

### Structural properties

Each of these is a property of the built binary, not a policy statement:

- **No network code.** No `URLSession`, no `Network.framework`, no sockets. There
  is no update check, no telemetry, no crash reporting.
- **No incoming channels.** No URL scheme, no XPC service, no CLI, no AppleScript
  dictionary, no distributed notifications. Nothing outside the app can ask it to
  do anything. This is what stops another process from borrowing the Accessibility
  grant through us.
- **No outgoing automation.** No AppleEvents, no `NSAppleScript`, no subprocess
  spawning. The app talks to other applications only through the window-management
  APIs it needs to raise a window.
- **No screen capture.** No `CGWindowListCreateImage`, `CGDisplayStream` or
  ScreenCaptureKit symbols anywhere in the source.
- **No third-party runtime dependencies.** The bundle links only Apple frameworks.
  Build-time tools (XcodeGen, SwiftLint) never enter the bundle.
- **No dynamic code loading**, except the single private-API shim in S03, which is
  confined to one allowlisted file and resolves a fixed list of SkyLight symbols.
- **No sandbox** — technically impossible alongside `CGEventTap` and cross-app
  window control. **Hardened Runtime** is on, with no exceptions: in particular
  `disable-library-validation` and `allow-dyld-environment-variables` stay off, so
  foreign code cannot be injected into a process that holds Accessibility.

### Data at rest

Only user settings — the shortcut, feature flags, appearance — in `UserDefaults`.
No application names, no bundle identifiers, no usage history, no exclusion lists.
The MRU order lives in memory and dies with the process. The user's habits leave no
trace on disk that another process running as the user could read.

### Keyboard events

The event tap observes every key event the system delivers to it; this cannot be
narrowed. It is contained instead:

- exactly one module receives raw `CGEvent`s;
- it converts them to a small internal command enum (`activate`, `next`, `previous`,
  `cancel`, `commit`) and nothing else crosses the module boundary;
- key codes, modifier state and event contents are never stored, never written to
  disk, and never logged — including in DEBUG builds. The one exception is the
  combination the user deliberately records as their shortcut (S13), which is a
  setting they chose rather than input that was observed;
- events that do not match the configured shortcut are passed through untouched;
- the shortcut recorder installs a second tap that sees one keystroke of the user's
  choosing, and only while the settings window is recording. It is created when the
  recorder is clicked and torn down as soon as a shortcut is captured, Escape is
  pressed, or the window stops being key.

### Logging

`os.log` only, for state transitions and error conditions. Every interpolated value
is `private` by default. Key codes, application names and window titles are never
logged at any build configuration or log level.

### Signing and distribution

Ad-hoc signing; no Apple Developer Program, decided deliberately. Accepted
consequences, to be documented for users rather than hidden:

- the Accessibility grant is tied to the code signature, so it must be granted
  again after every update or rebuild;
- TCC rows are tied to the same signature, so a row left over from an older build can
  keep **denying** Input Monitoring to a build that never asked for it, which strips
  key presses from the tap without saying so;
- a downloaded build carries the quarantine attribute and needs
  System Settings → Privacy & Security → Open Anyway on macOS 15+;
- distribution is via source build and a project-owned Homebrew tap.

The app must therefore *detect* that it has lost the Accessibility grant and explain
why, rather than silently doing nothing. That behaviour is specified in S10, and the
tap that stays alive while macOS withholds key presses from it in S15.

### Supply chain

- Release artefacts are built only by GitHub Actions from a tag, with build
  provenance attestation and SHA-256 published in the release notes.
- Every pull request from outside is reviewed before merge; `main` is protected.
- The structural properties above are enforced in CI by a source guard, so a
  malicious or careless contribution that adds a forbidden API fails the build
  instead of relying on a reviewer noticing.

## Definition of Done

- [ ] A CI guard fails the build when any forbidden API appears in the sources.
- [ ] The forbidden-API list and its single allowlisted exception are in version control.
- [ ] The generated `Info.plist` declares no URL types and no usage descriptions
      beyond those actually required.
- [ ] The entitlements file enables Hardened Runtime with no exceptions.
- [ ] `README.md` and `README.ru.md` state the ad-hoc signing consequences plainly.
- [ ] A runbook exists for verifying, on a real machine, that the built app makes no
      network connections and requests no permission other than Accessibility.

## Test cases

| # | Case | Expected |
|---|------|----------|
| 1 | Source guard over a file using `URLSession` | fails, names file and symbol |
| 2 | Source guard over a file using `NWConnection` or `Network` import | fails |
| 3 | Source guard over a file using `CGWindowListCreateImage` / `SCStream` | fails |
| 4 | Source guard over a file using `NSAppleScript` / `NSAppleEventDescriptor` | fails |
| 5 | Source guard over a file using `NSXPCConnection` / `Process` / `NSTask` | fails |
| 6 | Source guard over a file using `DistributedNotificationCenter` | fails |
| 7 | `dlopen` in the allowlisted SkyLight shim | passes |
| 8 | `dlopen` in any other file | fails |
| 9 | Source guard over the current clean tree | passes |
| 10 | Settings storage asked to persist an application name | rejected at the type level |
| 11 | Log call built from a key code | rejected at the type level |
| 12 | Non-matching key event enters the tap | passed through unchanged, no state retained |

Cases 10 and 11 are compile-time guarantees: the settings and logging APIs are typed
so that the value simply cannot be passed, rather than checked at runtime.

## Manual runbook

Run on the real machine after any change to the event tap, the settings store or the
build configuration.

1. `codesign -d --entitlements - /Applications/humane-space-tab.app`
   → Hardened Runtime present; no `disable-library-validation`,
   no `allow-dyld-environment-variables`, no `apple-events`.
2. `otool -L` on the binary → only `/System/Library/…` and `/usr/lib/…`; no bundled
   third-party dylibs.
3. Launch the app, use the switcher for a few minutes, then open
   System Settings → Privacy & Security → **Screen Recording**
   → the app is absent from the list. It must never appear there.
4. With Little Snitch (or `lsof -i -a -p $(pgrep humane-space-tab)`) observe the
   process for a full session → zero network connections, zero DNS lookups.
5. `defaults read <bundle-id>` → shortcut and flags only; no application names, no
   usage history.
6. `log show --predicate 'subsystem == "<subsystem>"' --last 1h` after using the
   switcher → no key codes, no application names, no window titles.

## Risks and open questions

- **Accessibility is a broad grant, and no design removes that.** A user who trusts
  the app trusts the source and the build. The mitigation is that the source is
  small, dependency-free, GPL-licensed, and machine-checked — not that the
  permission is somehow narrowed.
- **Ad-hoc signing weakens the distribution story** and trains users to bypass
  Gatekeeper. Accepted, documented, revisited only if a Developer ID is obtained.
- **The private SkyLight shim is the one hole in "no dynamic loading".** Its symbol
  list is fixed and reviewed; S03 defines the degradation path when a symbol is
  missing.
- **Open:** whether the source guard runs as a Swift test or a standalone CI script.
  Decided in S01, once the module layout exists.
- **Open:** the exact subsystem and category naming for `os.log`. Decided in S01.
