# humane-space-tab

A humane app switcher for macOS: `Cmd+Tab` restricted to the applications of the current
Space. Menu bar agent (`LSUIElement`), macOS 15+, Swift 6, no external dependencies, no
network. Pre-release — releases stay below `1.0`.

## Commands

```sh
swift test                                                            # 536 Swift Testing tests in four targets, ~3s
swiftlint lint --quiet --strict
swift format lint --recursive --strict Sources Tests Package.swift     # `swift-format lint …` in CI
swift build --build-tests
xcodegen generate                                                     # regenerates the .xcodeproj, never committed
scripts/package.sh <version> [build]                                  # dist/…zip, …dmg, SHA-256
scripts/install.sh <version> [build]                                  # packages, installs into /Applications, relaunches
```

Tools: `brew install xcodegen swiftlint` plus Xcode 26 or later. Swift language mode 6,
strict concurrency complete; this machine builds it with Xcode 27 / Swift 6.4 on macOS 27,
while CI runs the `macos-26` image.

## Layout

Ports and adapters, one direction only:

```
SwitcherCore    pure logic, no system frameworks
SystemPorts     the protocols the logic needs
SystemAdapters  AppKit / CoreGraphics / Accessibility behind those protocols
SwitcherUI      the ribbon and the settings window
App             the bundle: wiring, delegate, menu bar
```

Anything decidable without the system belongs in `SwitcherCore` and is unit-tested there.
No system framework call outside `SystemAdapters` and `SwitcherUI`.

## Non-negotiable

- **No new permissions, no new dependencies.** Accessibility and system frameworks only.
  `Tests/SourceGuardTests` scans the sources and fails the build on network, screen
  capture, AppleEvents, IPC, subprocess and dynamic-loading API.
- **A spec before a feature.** `docs/specs/` holds what a thing does, how it fails, its
  definition of done, test cases and a manual runbook. Read
  [S00 — threat model](docs/specs/S00-threat-model.md) before touching anything the app is
  allowed to see; its commitments are not open inside a feature PR.
- **The runbook, updated in the same commit** as the behaviour it checks.
- **Branch off `dev`.** `main` is the release branch.
- **English commits**, imperative, explaining why rather than restating the diff.

## More

`CONTRIBUTING.md` — building, packaging, what a change carries. `docs/specs/README.md` —
the design, spec by spec. `docs/glossary.md` — the interface terms and their fifteen
translations. `.context/` — the working notes for an agent session (conventions, checks,
architecture map).
