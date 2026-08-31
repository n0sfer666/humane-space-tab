# S14 — Overlay mouse interaction

**Status:** agreed · **Depends on:** S05, S06, S07, S16 · **ADRs:** —

## Goal

The ribbon is on screen and the user's hand is already on the mouse. S14 lets them
point at the application they want instead of counting `Tab`s: hovering moves the
selection, clicking switches, scrolling steps. The keyboard keeps working exactly as
it does now — the two drive one selection, not two.

## Non-goals

- **Dismissing the ribbon by clicking outside it.** That needs a monitor on every mouse
  event on the screen, which is precisely the kind of watching S00 refuses. The session
  still ends the way it always did: Command released, `Escape`, or the idle watchdog.
- **Making the app frontmost.** Clicking our own panel must not activate us; the panel
  stays `.nonactivatingPanel`, and the only application that comes forward is the one
  the user picked.
- **Drag, right-click menus, close buttons on tiles.** One gesture per pointer action,
  nothing modal, nothing destructive from inside a switcher.
- **Window previews.** Still never — Screen Recording (S00).

## Design

### The panel stops ignoring the mouse

S07 set `ignoresMouseEvents = true` because there was nothing to click. S14 sets it to
`false`, and the panel is only ever on screen while a session is open, so a click over
the ribbon reaching us instead of the window underneath is a click the user aimed at
the ribbon. Off screen, the panel intercepts nothing at all.

### Hovering selects, but only after the mouse moves

A pointer that merely happens to rest where the ribbon appears must not steal the
selection the keyboard just made: the ribbon opens under the mouse far more often than
the user means to point at it. The rule is therefore movement, not presence — the
selection follows `mouseMoved` and `mouseDragged`, and `mouseEntered` changes nothing.
A stationary cursor is invisible to the ribbon no matter what it sits on top of; one
nudge and the ribbon follows it.

### Hit testing is arithmetic

Where a point lands is decided by `RibbonHitTest`, a pure function over the layout the
ribbon was drawn with — no AppKit, no view tree, unit-tested like `OverlayLayout` and
`CarouselWindow` beside it. Each slot claims its icon plus half the gap on either side,
so the ribbon has no dead stripes between tiles, and a point outside the panel or past
the last slot claims nothing.

A slot is a place in the ribbon, not an application: the ribbon is a carousel (S07) at
every count, so the same slot carries a different entry after every step. So the hit test answers a slot, and the
pointer's meaning is read through the window the ribbon was last drawn with — the click
commits the entry the user is looking at, not the one that stood there a step ago.

### Clicking is the same commit the keyboard makes

Mouse-up on the slot its mouse-down started on selects that entry and commits it
immediately — the ribbon closes and the target comes forward even though Command is
still held, which is what the system switcher does and what a click means everywhere
else. Commit runs through `SwitcherCoordinator` unchanged, so activation, the MRU
record, and S16's window raise are the ones the keyboard already uses. Command going up
afterwards finds no session and is ignored.

### Scrolling steps the selection

A scroll over the ribbon moves the selection one entry per notch, forward when the
gesture goes down or right. `ScrollSteps` accumulates the deltas and emits whole steps,
so a trackpad's stream of fractional deltas moves the selection at a readable pace
instead of flying through the ribbon, and momentum is dropped: the inertial tail of a
flick would keep stepping after the fingers left the glass, and a switcher that keeps
moving on its own is a switcher that switches to the wrong thing.

Scrolling is also the only way the mouse reaches a Space with more than ten
applications, where S07 turns the ribbon into a carousel: the entries the pointer cannot
see, it can now bring into view.

### One selection, one path

`SwitcherMachine` gains `select(_:)` — the same guarded mutation `step` is, reporting
`.moved` only when the selection actually changed, so an unchanged hover neither
redraws the ribbon nor re-arms anything. The gestures travel out of the view as a
`RibbonGesture` and reach the coordinator through the same emit closure the tap uses;
there is no second path into the state machine and no new system port, because the
mouse is already AppKit's and needs no permission.

Because every gesture ends in a render, the idle watchdog is re-armed by mouse activity
for free: a ribbon being pointed at is not a stranded one.

## Definition of Done

- [ ] Moving the mouse over a tile selects it; the ribbon appearing under a still cursor selects nothing.
- [ ] Clicking a tile switches to it immediately, with Command still held, and closes the ribbon.
- [ ] Clicking the ribbon does not make the switcher the frontmost application.
- [ ] Scrolling over the ribbon steps the selection one entry per notch, in both directions, and ignores momentum.
- [x] A hover that lands on the already selected tile changes nothing and redraws nothing.
- [x] Hit testing is pure and unit-tested: tiles, gaps, outside the panel, past the last slot.
- [x] A click commits the entry the slot carries now, not the one it carried before the step — at any number of applications.
- [x] Mouse and keyboard share one selection: a `Tab` after a hover continues from the hovered tile.
- [ ] With window switching on (S16), pointing and clicking picks the window, not just its application.
- [ ] Off screen, the panel still lets every click through to the application underneath.
- [x] The whole suite is green; `swift-format --strict` and `swiftlint --strict` are clean.
- [x] The Release bundle still declares zero entitlements and links no non-system library.

The unticked boxes are what only a pointer on a real screen can answer; they are steps
1–8 of the runbook below. Everything the arithmetic decides — where a point lands, what a
click means, how far a scroll goes, and that an unchanged hover costs nothing — is ticked
because it is unit-tested.

## Test cases

| # | Case | Expected |
|---|------|----------|
| 1 | hit test, a point on a tile | that index |
| 2 | hit test, a point in the gap between two tiles | the nearer tile, no dead stripe |
| 3 | hit test, a point outside the panel | nothing |
| 4 | hit test, a point past the last slot | nothing |
| 5 | hit test, a crowded Space | the slot under the pointer, and the entry that slot carries |
| 6 | hit test, an empty ribbon | nothing |
| 7 | machine, select a different index | `.moved`, selection follows |
| 8 | machine, select the current index | `.ignored` |
| 9 | machine, select out of range | `.ignored` |
| 10 | machine, select with no session | `.ignored` |
| 11 | scroll steps, a delta below the threshold | no step, the delta is kept |
| 12 | scroll steps, deltas summing past the threshold | one step, the remainder is kept |
| 13 | scroll steps, a large delta | one step per threshold crossed |
| 14 | scroll steps, direction | down and right step forward, up and left backward |
| 15 | scroll steps, the dominant axis | the larger of the two deltas decides |
| 16 | presenter, a hover gesture | select reaches the coordinator, the ribbon is re-rendered |
| 17 | presenter, a click gesture | select then commit, the ribbon is hidden |
| 18 | presenter, a gesture with no session | nothing is emitted |

## Manual runbook

1. Hold Command, press `Tab`, keep holding, and move the mouse over the ribbon →
   expected: the selection follows the pointer, the name under the icons changes with it.
2. Repeat, but park the pointer where the ribbon will appear and press `Cmd+Tab` without
   touching the mouse → expected: the keyboard's selection stands; the tile under the
   cursor is not selected until the mouse moves.
3. Hover a tile, then press `Tab` → expected: the selection continues from the hovered
   tile, not from where the keyboard left it.
4. Click a tile while still holding Command → expected: that application comes forward at
   once, the ribbon disappears, and releasing Command does nothing extra.
5. Scroll over the ribbon with a wheel and with two fingers → expected: one entry per
   notch, both directions; a flick does not keep stepping after the fingers lift.
6. On a Space with more than ten applications, scroll until an application that was off
   the ribbon comes into view, then click it → expected: the icons move under a still
   selection, and the application that comes up is the one whose icon was clicked.
7. With window switching on, hover and click a window of an application that has several →
   expected: that window is raised, not merely its application.
8. Without the ribbon on screen, click where it was → expected: the click lands in the
   application underneath, as it always did.

## Risks and open questions

- **Mouse-moved delivery to a non-key panel.** A borderless, non-activating panel that is
  never key still receives tracked mouse-moved events through an `.activeAlways` tracking
  area; runbook step 1 is the check that it does.
- **A click that starts on one tile and ends on another.** Treated as no click at all,
  the way a button treats a drag off itself; the alternative is switching to something
  the user pointed away from.
- **The scroll threshold is a judgement call.** It is set for a wheel notch and checked
  against a trackpad in step 5; if it reads too fast or too slow it becomes a number in
  `OverlayMetrics`, not a preference — a switcher with a scroll-speed setting is a
  switcher that has stopped being humane.
