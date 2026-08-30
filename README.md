# humane-space-tab

A humane app switcher for macOS.

macOS switches between **all** open applications on `Cmd+Tab`, regardless of which
virtual desktop (Space) they live on. `humane-space-tab` restricts switching to the
applications of the **current Space** — and, further, aims to extend the same
Space-aware behaviour to the other grouping, hiding and revealing gestures of macOS.

> **Status: early design.** No usable build yet. The project is being specified in
> small, reviewable mini-specs before code is written.

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
  logged or forwarded;
- hardened runtime, no entitlements beyond what is strictly required;
- everything auditable — the full source is here, under GPL-3.0.

The app asks for **Accessibility and nothing else**. It never requests Screen
Recording, which means it deliberately does not show window previews — that
feature is the reason comparable switchers hold a permission that can read the
contents of every window on your screen.

Builds are **ad-hoc signed** — there is no Apple Developer ID. Two consequences you
should know about before installing: macOS will ask you to grant Accessibility
again after every update, and a downloaded build must be allowed once through
System Settings → Privacy & Security.

The full threat model is [S00](docs/specs/S00-threat-model.md).

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

## Licence

[GPL-3.0](LICENSE)
