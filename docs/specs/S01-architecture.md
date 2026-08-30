# S01 — Architecture and modules

**Status:** agreed · **Depends on:** [S00](S00-threat-model.md) · **ADRs:** [0001](../adr/0001-foundation.md)

## Goal

Establish the module layout, the concurrency model and the build skeleton, so that
every later spec has a place to put its logic where it can be tested, and its system
calls where they cannot leak. Ends with a launchable — if inert — signed app bundle
produced by CI.

## Non-goals

- Any switching behaviour. The app does nothing but sit in the menu bar and quit.
- The event tap itself (S04), the window inventory (S02), Space attribution (S03).
- Settings storage (S08) and the permission flow (S10).

## Design

### Modules

```
SwitcherCore    pure logic and domain types. Imports Foundation only —
                never AppKit, never CoreGraphics, never ApplicationServices.
SystemPorts     protocols describing what the app needs from the system.
                Imports SwitcherCore. No implementations.
SystemAdapters  thin implementations of those protocols on top of the real
                system APIs. Imports SystemPorts and the system frameworks.
SwitcherUI      AppKit presentation. Imports SwitcherCore and SystemPorts.
App             composition root: builds the object graph and starts the app.
                The only place allowed to import SystemAdapters.
```

Dependencies point inwards only. `SwitcherCore` cannot import a system framework —
that is enforced by the compiler, not by discipline, which is the reason for the
split. The forbidden-API guard from S00 enforces the rest.

`App` is an Xcode target rather than an SPM executable, because the `.app` bundle
needs `Info.plist`, entitlements and signing. `project.yml` wires it to the local
package; the `.xcodeproj` is generated and never committed.

### Concurrency

- The event tap is attached to the **main run loop** (S04), so its callback runs on the
  main thread and is entered with `MainActor.assumeIsolated`. The earlier plan of a
  dedicated tap thread was dropped: everything the callback hands work to is
  `@MainActor`, and a second thread would only buy a hop plus a queue.
- The callback is synchronous and never awaits, never touches UI, never calls the
  Accessibility API. It may do bounded main-actor work — classify the event, take the
  Space snapshot, advance the switcher state (S05) — as long as that work stays far
  under the ~1 s the system allows before `kCGEventTapDisabledByTimeout`. Measured
  budget lives in the spec of whatever the callback calls; S05 measures the snapshot.
- Because the tap can still be disabled (timeout, or user input during a modifier
  hold), re-arming it is a **recovery point**: the adapter cancels an open switcher
  session there, so a lost `flagsChanged` release cannot wedge the session open.
- The boundary carries only `Sendable` command values, never `CGEvent`.
- No custom actors. An actor cannot be awaited from inside the tap callback, so it
  would add ceremony without buying isolation where isolation is actually needed.

### Composition root

The object graph is assembled by hand in `App`, with no container and no reflection.
Every dependency is a protocol from `SystemPorts`, passed to the initialiser. Tests
substitute fakes at the same seams.

### Logging

`LogEvent` is a closed enum of state transitions, with no associated string payload.
`LogSink` takes a `LogEvent` and nothing else. Application names, window titles and
key codes are therefore not merely "not logged" — there is no parameter to put them
in. The `os.log` adapter uses subsystem `io.github.n0sfer666.humane-space-tab` and
one category per module.

### Forbidden-API guard

A Swift Testing suite that scans `Sources/` for the symbols S00 forbids. It is a
pure function over `(filename, contents)`, so it is itself covered by fixture tests
rather than only by its effect on the tree. Its rule table — symbol, reason, and the
single allowlisted file for `dlopen` — lives in version control next to the tests.
Running as part of `swift test` means a violation goes red in the local TDD loop, not
only after a push.

### Tooling

`swift format` from the Swift 6.3 toolchain owns layout; SwiftLint owns what layout
cannot express — complexity, file length, force unwraps. The two overlap on trailing
commas and import order and disagree there, so those SwiftLint rules are off: one tool
per question. Configuration lives in `.swift-format` and `.swiftlint.yml`.

CI runs, on every push and pull request: the test suite, `swiftlint --strict`,
`swift-format lint --strict`, the release bundle build, and three assertions on the
built bundle — it carries no entitlements, Hardened Runtime is on, and nothing outside
`/System/Library/Frameworks` and `/usr/lib` is linked.

## Definition of Done

- [x] `swift build` and `swift test` succeed from a clean checkout.
- [x] The five modules exist with the dependency directions above; a deliberate
      `import AppKit` in `SwitcherCore` fails to compile.
- [x] The guard suite passes on the tree and rejects each seeded fixture.
- [x] `xcodegen generate && xcodebuild` produces a launchable `.app`.
- [x] The app appears in the menu bar and shows no Dock icon; quitting from its menu
      is checked by the runbook.
- [x] The release bundle carries **no** entitlements at all and is signed with
      Hardened Runtime; `Info.plist` declares no URL types and no permission usage
      descriptions.
- [x] CI is green on `dev` and required for merging into `main`.

## Test cases

| # | Case | Expected |
|---|------|----------|
| 1 | Guard over a fixture containing `URLSession` | one violation, names symbol and file |
| 2 | Guard over fixtures for each forbidden symbol group | one violation each |
| 3 | Guard over a fixture containing `dlopen` in the allowlisted file | no violation |
| 4 | Guard over a fixture containing `dlopen` elsewhere | one violation |
| 5 | Guard over a fixture where the symbol appears as part of a longer identifier | no violation |
| 6 | Guard over the real `Sources/` tree | no violations |
| 7 | Guard over a fixture where the symbol is a prefix of a longer word | no violation |
| 8 | `LogEvent` carries no associated values | `Mirror` shows no children for any case |
| 9 | Every `LogEvent` case has a non-empty message, unique across cases | pass |
| 10 | Every `LogCategory` raw value is a lowercase identifier | pass |

There is no test for a `LogSink` fake: the protocol has one method and no logic, and a
test over a fake would assert nothing but the fake. The seam is exercised for real by
the runbook, which reads the events out of the unified log.

## Manual runbook

Run from the repository root. `APP` below is
`.build/xcode/Build/Products/Release/HumaneSpaceTab.app`.

1. `xcodegen generate && xcodebuild -project HumaneSpaceTab.xcodeproj -scheme HumaneSpaceTab
   -configuration Release -derivedDataPath .build/xcode build`
   → ends with `** BUILD SUCCEEDED **`.
2. `codesign -dv "$APP"` → `flags=0x10002(adhoc,runtime)`.
   `codesign -d --entitlements - "$APP"` → prints the executable path and nothing else:
   no `[Key]` lines.
3. `otool -L "$APP/Contents/MacOS/HumaneSpaceTab"` → every line is under
   `/System/Library/Frameworks` or `/usr/lib`.
4. `open "$APP"` → an icon appears in the menu bar; **no** Dock icon, no window, no
   permission prompt of any kind.
5. `/usr/bin/log show --last 5m --info --debug
   --predicate 'subsystem == "io.github.n0sfer666.humane-space-tab"' --style compact`
   → exactly `application did launch` under `lifecycle` and `menu bar item installed`
   under `ui`; no other data. (`log` is shadowed in Nushell — use the absolute path.)
6. Menu bar icon → **Quit Humane Space Tab** → the process exits;
   `pgrep -f HumaneSpaceTab` returns nothing, and the log gains
   `quit requested from menu` and `application will terminate`.

## Risks and open questions

- **Ad-hoc signing during development** means macOS treats each rebuild as a new
  application. Harmless now, becomes visible in S04 when Accessibility is first
  needed; handled in S10.
- **Xcode injects `com.apple.security.get-task-allow` into ad-hoc signed builds**,
  which lets any process attach a debugger to the app. It is off for Release via
  `CODE_SIGN_INJECT_BASE_ENTITLEMENTS: NO`, kept on for Debug so local debugging still
  works, and CI fails the build if any entitlement reappears in a Release bundle.
- **The guard is textual.** It catches the symbols it knows about; it cannot catch a
  novel way of reaching the network. It is a floor, not a ceiling — review still
  matters, which is why external pull requests are reviewed regardless.
- **Open:** whether `SystemPorts` stays one module or splits per domain once S02–S04
  land. Deferred until there is enough in it to judge.
