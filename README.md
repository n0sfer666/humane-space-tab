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

This is a design commitment, not yet an implemented and audited state. The
detailed threat model will land as its own mini-spec under `docs/specs/`.

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

## Licence

[GPL-3.0](LICENSE)
