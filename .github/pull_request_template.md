## What this changes

<!-- The behaviour, in a sentence or two. Why, not a restatement of the diff. -->

Spec / issue:

## How it was verified

<!--
Tick what you ran. Much of this app is only visible on a live desktop, so say what you
checked by hand and what you saw — "the ribbon listed only this Space's applications on
a two-Space setup" beats "tested manually".
-->

- [ ] `swift test`
- [ ] `swiftlint lint --strict`
- [ ] `swift format lint --recursive --strict Sources Tests Package.swift`
- [ ] Ran the built app (`scripts/install.sh <version>`) and used the gesture

By hand:

## The commitments

- [ ] No new permission is requested — Accessibility and nothing else.
- [ ] No network code, no AppleEvents, no plugins, no subprocesses, no new dependency.
- [ ] Nothing new is logged or written to disk about what the user typed or has open.
- [ ] The spec and its manual runbook match what the code now does.

<!--
If a box cannot be ticked, say why here rather than removing it. A deliberate exception
discussed in the open is fine; a silent one is not.
-->
