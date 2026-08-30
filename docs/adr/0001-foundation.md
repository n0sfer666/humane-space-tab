# ADR 0001 — Foundation

**Status:** accepted · **Date:** 2026-08-30

Decisions taken before any code was written. Each was an explicit choice between
alternatives; the rejected ones are recorded because they are likely to be
proposed again.

## Language and UI: Swift 6 + AppKit

Maximum nativeness, smallest bundle, lowest memory, and full control over the
`NSPanel` window level the overlay needs in order to appear above every other
window on the current Space.

*Rejected:* SwiftUI (larger runtime and memory, and an overlay of this kind ends
up wrapped in an `NSPanel` anyway, so the control is lost without the saving);
AppKit + embedded SwiftUI (pulls in both runtimes); Objective-C (no memory-safety
or readability benefit in 2026).

## Shortcut: intercept `Cmd+Tab`, but make it configurable

`Cmd+Tab` is taken over by default, because that is the literal problem being
solved. The combination is configurable, and a mode that leaves the system
switcher untouched is supported.

Interception requires a `CGEventTap`, which requires the **Accessibility**
permission. Known failure mode: if the permission is revoked or the tap is
disabled by the system, macOS silently falls back to its own switcher — the app
must detect this and re-arm rather than fail quietly.

*Rejected:* a non-system shortcut only (e.g. `Option+Tab`) — lower risk, but it
does not solve the stated problem.

## Space membership: public API as the base, private API as an opt-in layer

The public API cannot tell which Space a window belongs to.
`CGWindowListCopyWindowInfo` with `kCGWindowListOptionOnScreenOnly` approximates
"windows on the current Space" but misses minimised and hidden windows. Exact
membership is only available through the private SkyLight/CGS calls
(`CGSCopySpacesForWindows` and relatives), which may break on any major macOS
release.

The public path is therefore the always-working base; the private path is a
feature-flagged layer, probed at runtime, that degrades to the public path when
the symbols or their behaviour change. Correctness is maximised without making a
macOS update able to brick the app.

*Rejected:* private API only (a single macOS release can break everything);
public API only (minimised and hidden apps cannot be attributed to a Space, so
the problem is only partly solved).

## Minimum macOS: 15 Sequoia

Modern API surface and a smaller compatibility matrix to test the Space logic
against.

*Rejected:* macOS 14 (a third behaviour branch to verify by hand); macOS 26 only
(too narrow an audience for an open-source utility); macOS 13.

## Licence: GPL-3.0

Forks must stay open. Consistent with the project being fully open source and
free, and it raises the trust bar for an app that asks for Accessibility.
Accepted consequence: distribution through the Mac App Store is closed off.

*Rejected:* MIT and Apache-2.0 — both permit a closed, paid fork.

## Build: SPM modules + XcodeGen

All logic lives in Swift Package Manager modules, so `swift test` runs the TDD
loop in seconds and in CI without Xcode. `project.yml` is committed and the
`.xcodeproj` is generated, which keeps unmergeable `pbxproj` diffs out of git.

*Rejected:* a committed Xcode project (binary-ish diffs, slower test loop);
plain SPM with a hand-written bundling script (more custom build code);
Tuist (heavier than this project warrants).

## Tests: Swift Testing, test-first

`@Test` / `#expect`, parameterised cases, native `async/await` and tags. Fully
available on macOS 15.

*Rejected:* XCTest (more verbose, weaker with Swift 6 concurrency). It stays the
option for XCUITest later, if UI tests are ever added.

## Process

`main` is protected: pull requests only, green CI, linear history, no force
pushes or deletions. `dev` is the development branch. CI runs tests, the bundle
build, lint and format checks on every push and pull request. Every feature is
designed as a mini-spec in `docs/specs/` before implementation. Repository
artefacts are in English; the README is also maintained in Russian.
