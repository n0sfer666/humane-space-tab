# humane-space-tab

A humane app switcher for macOS.

macOS switches between **all** open applications on `Cmd+Tab`, regardless of which
virtual desktop (Space) they live on. `humane-space-tab` restricts switching to the
applications of the **current Space** — and, further, aims to extend the same
Space-aware behaviour to the other grouping, hiding and revealing gestures of macOS.

> **Status: pre-release.** The switcher works. The roadmap still changes behaviour you
> can see, so releases stay below `1.0`.

[Русская версия](README.ru.md)

## Goals

- **Native first** — Swift 6 + AppKit, no cross-platform runtime.
- **Small footprint** — minimal bundle size and memory usage.
- **UI/UX** — the switcher should feel like part of the system, not an add-on.
- **Launch at login** — opt-in, via the system-supported mechanism.
- **Security** — the app requires Accessibility to work; the design deliberately
  minimises what it can do with it. See [Security](#security).

## Security

`humane-space-tab` needs the macOS **Accessibility** permission: intercepting
`Cmd+Tab` and raising other applications' windows is impossible without it. That
permission is broad, so the threat model matters more than usual here. The
project's standing commitments:

- no network access of any kind;
- no AppleEvents / scripting bridge into other applications;
- no plugin system and no user-supplied code or scripts;
- keystrokes are inspected only to match the configured shortcut, never stored,
  logged or forwarded — the sole exception is the combination you deliberately
  record as your own shortcut;
- window titles are read only while the optional window switching is turned on, and
  only to be drawn on the ribbon: never logged, never written to disk, never sent
  anywhere;
- the pointer is seen only over the ribbon's own panel, and only while the ribbon is
  on screen: no global mouse monitoring, nothing recorded anywhere;
- hardened runtime, no entitlements beyond what is strictly required;
- everything auditable — the full source is here, under GPL-3.0.

The app asks for **Accessibility and nothing else**. It never requests Screen
Recording, which means it deliberately does not show window previews — that
feature is the reason comparable switchers hold a permission that can read the
contents of every window on your screen. It never asks for Input Monitoring
either; where a stale entry in that list makes macOS withhold key presses, the
menu bar says so and offers the pane that can undo it.

Builds are **ad-hoc signed** — there is no Apple Developer ID. Two consequences you
should know about before installing: macOS will ask you to grant Accessibility
again after every update, and a downloaded build must be allowed once through
System Settings → Privacy & Security.

The full threat model is [S00](docs/specs/S00-threat-model.md).

## Install

Download the latest zip from [Releases](../../releases), unpack it and move
**Humane Space Tab.app** to `/Applications`.

The first launch is refused: macOS quarantines a downloaded build that carries no
Developer ID. Open **System Settings → Privacy & Security**, scroll to the bottom and
press **Open Anyway**, then launch the app again. Do not strip the quarantine attribute
by hand — that habit disarms the check that protects you from everything else you
download.

The app asks for Accessibility as it launches, and its menu bar icon shows a warning
until the grant is there — **Grant Accessibility…** in that menu asks again. Either way
the switcher starts working within a couple of seconds, without a relaunch. macOS ties
the grant to the code signature, so it has to be given again after every update.

A menu bar with no free slot left of the notch drops the icon: macOS draws no status item
it cannot fit, and nothing in the app can claim the space. Free a slot, or open the app
again from Finder or Spotlight — a second launch opens Settings instead of a new copy.

If the icon instead says macOS is withholding key presses, an old entry for the app is
denying it in **System Settings → Privacy & Security → Input Monitoring**. Remove that
entry with **−** — the app does not need the permission, only the absence of a refusal —
and click back into the app; the tap is rebuilt without a relaunch.

### Verify what you downloaded

```sh
shasum -a 256 HumaneSpaceTab-<version>.zip          # compare with the release notes
gh attestation verify HumaneSpaceTab-<version>.zip --repo n0sfer/humane-space-tab
```

The attestation ties the artefact to the workflow run and the commit that built it.

## Requirements

- macOS 15 Sequoia or later
- Apple Silicon or Intel

## Development

- **Language:** Swift 6, AppKit
- **Build:** Swift Package Manager for the logic modules, XcodeGen for the `.app` bundle
- **Tests:** Swift Testing, test-driven — tests come first
- **Branches:** `main` is the protected release branch, `dev` is where development happens
- **Specs:** every feature is designed as a mini-spec in `docs/specs/` before it is built;
  foundational decisions are recorded as ADRs in `docs/adr/`

Requires Xcode 26 and `brew install xcodegen swiftlint`.

```sh
swift test
swiftlint lint --strict
swift format lint --recursive --strict Sources Tests Package.swift
xcodegen generate
xcodebuild -project HumaneSpaceTab.xcodeproj -scheme HumaneSpaceTab \
  -configuration Release -derivedDataPath .build/xcode build
```

The Xcode project is generated from `project.yml` and is never committed.

Packaging is one script — the release workflow only calls it, so it can be run and broken
on a laptop instead of at production:

```sh
scripts/package.sh 0.1.0        # dist/HumaneSpaceTab-0.1.0.zip and its SHA-256
```

It refuses to produce anything that is missing an architecture, carries entitlements,
lacks the hardened runtime, links a non-system library or fails signature verification —
and it checks each slice of the universal binary separately, because `codesign` and
`otool` report only the host slice by default. A `v*` tag runs the same
script in CI and publishes a pre-release; the details are in
[S11](docs/specs/S11-packaging-release.md).

Installing a build you made yourself is one script on top of it:

```sh
scripts/install.sh 0.1.0        # packages, replaces /Applications/Humane Space Tab.app, relaunches
```

It packages first, so it never installs a bundle that failed a check; it quits the
running app, replaces the bundle, verifies the installed version and launches it. Expect
the last lines to read `==> /Applications/Humane Space Tab.app is 0.1.0, running as pid …`
followed by the reminder that Accessibility has to be granted again — every local build
carries its own ad-hoc signature, and macOS ties the grant to the signature.

## Licence

[GPL-3.0](LICENSE)
