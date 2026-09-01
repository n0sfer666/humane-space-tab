# Contributing

Bug reports, ideas and patches are all welcome. This file says how the project is built
and what a change is expected to carry with it, so that a pull request does not turn into
a list of surprises.

## Getting it running

```sh
brew install xcodegen swiftlint     # Xcode 26 is the other requirement
swift test                          # the logic modules
xcodegen generate                   # regenerates HumaneSpaceTab.xcodeproj, never committed
scripts/install.sh 0.1.0            # packages, installs into /Applications, relaunches
```

`scripts/install.sh` replaces the copy in `/Applications` with the one you just built.
Every local build carries its own ad-hoc signature, so macOS asks for Accessibility again
each time — that is the system, not the script.

## How the code is laid out

Ports and adapters, one direction only:

```
SwitcherCore    pure logic, no system frameworks
SystemPorts     the protocols the logic needs
SystemAdapters  AppKit / CoreGraphics / Accessibility behind those protocols
SwitcherUI      the ribbon and the settings window
App             the bundle: wiring, delegate, menu bar
```

A rule that keeps paying for itself: anything decidable without the system belongs in
`SwitcherCore` and is unit-tested there. Adapters stay thin enough to be read in one
sitting, because they are the part tests cannot reach.

## Before a feature, a spec

Features are designed in `docs/specs/` before they are built — what the thing does, how
it fails, a definition of done, test cases, and a manual runbook for whatever a test
cannot see. Foundational decisions go to `docs/adr/`. A pull request that adds behaviour
without a spec will be asked for one; the spec is where the argument happens, and it is
cheaper there.

Read [S00](docs/specs/S00-threat-model.md) first if the change touches anything the app is
allowed to see. Its commitments are not negotiable inside a feature PR.

## What a change carries

- **Tests first.** The suite is Swift Testing; 400-odd tests run in well under a second,
  so there is no reason to skip them.
- **Green checks.** `swift test`, `swiftlint lint --strict`, and
  `swift format lint --recursive --strict Sources Tests Package.swift`. CI runs all three.
- **No new permissions and no new dependencies.** The app asks for Accessibility and
  nothing else, and links system frameworks only. A test scans the sources for network,
  AppleEvents, plugin and subprocess API and fails on a match.
- **The runbook, updated in the same commit.** If you changed what a person sees, change
  the steps that check it. A stale runbook does not fail — it quietly verifies last
  week's app.
- **English commits**, in the imperative, explaining why rather than restating the diff.

## Packaging

The bundle icon is drawn, not stored: `scripts/make-icon.sh` renders every size from
`scripts/icon.swift` and packs `Resources/AppIcon.icns`. Change the drawing, run the
script, commit the `.icns` it produced — packaging refuses a bundle without one.

Packaging itself is one script, and the release workflow only calls it, so it can be run
and broken on a laptop instead of at production:

```sh
xcodegen generate
xcodebuild -project HumaneSpaceTab.xcodeproj -scheme HumaneSpaceTab \
  -configuration Release -derivedDataPath .build/xcode build
scripts/package.sh 0.1.0        # dist/…zip, …dmg and a SHA-256 beside each
```

It refuses to produce anything that is missing an architecture, carries entitlements,
lacks the hardened runtime, links a non-system library or fails signature verification —
and it checks each slice of the universal binary separately, because `codesign` and
`otool` report only the host slice by default. The disk image is mounted again after it is
written, to make sure it carries both the app and the Applications shortcut.

`scripts/install.sh 0.1.0` packages first, so a bundle that failed a check never reaches
`/Applications`; then it quits the running app, replaces the bundle, verifies the
installed version and launches it. Expect the last lines to read
`==> /Applications/Humane Space Tab.app is 0.1.0, running as pid …` followed by the
reminder about Accessibility.

A `v*` tag runs the same script in CI, publishes a pre-release and updates the Homebrew
cask — [S11](docs/specs/S11-packaging-release.md) and [docs/homebrew.md](docs/homebrew.md)
have the details.

## Pull requests

Branch off `dev`; `main` is the release branch. Say in the description what you verified
and how — including what you had to check by hand, since much of this app is only visible
on a live desktop.

Comments in the code are for behaviour that is not obvious from reading it: a system quirk
worked around, an ordering that matters. Not for what the next line already says.
