# S07 — Overlay UI

**Status:** agreed · **Depends on:** S01, S04, S05, S06 · **ADRs:** —

## Goal

Show the user what they are switching to, and finally take over the shortcut: the
tap moves to `.intercept`, the system switcher stops appearing, and ours appears
instead — with the applications of the current Space only, which is the whole point
of the product.

## Non-goals

- Window previews. Never, in any release: they need Screen Recording (S00).
- Mouse interaction — hovering, clicking and scrolling a tile is [S14](S14-overlay-mouse.md).
- Per-window rows (`Cmd+~`, App Exposé) — S12+.
- Choosing which display to show on — S08; S07 uses the focused screen.
- Requesting or explaining the Accessibility permission — S10. S07 only degrades
  correctly when it is missing.

## Design

### AppKit, not SwiftUI

The overlay is built from `NSPanel` + `NSVisualEffectView` + plain `NSView`s.
SwiftUI would add a state-diffing pass on the keystroke path for a view that is a
row of icons and one label; measured warm, the AppKit panel is fully rebuilt in
9–10 ms and ordered on screen in under 1 ms. Layout is deterministic, and nothing
about it needs a declarative framework.

### The panel

| Property | Value | Why |
|---|---|---|
| `styleMask` | `[.nonactivatingPanel, .borderless]` | showing the overlay must not make us frontmost — measured: the previously frontmost application stayed frontmost, and the panel is neither key nor main |
| `level` | `.popUpMenu` | above ordinary and floating windows, below the screen saver |
| `collectionBehavior` | `.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle` | appears on whatever Space the user is on, including over a full-screen application, and never becomes a switch target itself |
| `ignoresMouseEvents` | `true`, until [S14](S14-overlay-mouse.md) gives the ribbon the pointer | S07 has no mouse interaction; clicks must reach the application underneath |
| `hidesOnDeactivate` | `false` | we are never active to begin with |
| `backgroundColor` | `.clear`, with the system's own panel material behind it and a 26 pt corner radius | native look, no custom chrome |

The panel is created once at launch and reused: a session updates its contents and
orders it front. Icons come from `NSRunningApplication.icon` — no permission, and no
cache of our own: measured over six applications, the first read costs 28 ms and every
later one 1.2 ms, because AppKit already caches the image. What we do instead is warm
it: launch reads the icons of the seeded applications, and opening a session warms the
snapshot in the gap before the ribbon appears, so an application launched after us pays
its first read there and never inside the tap callback.

### When it appears

A quick `Cmd+Tab` — press and release — must not flash a HUD. The overlay is therefore
scheduled, not shown, when a session opens: if the session is still open **120 ms**
later, it appears; if it committed or was cancelled first, it never existed. This is
what the system switcher does, and it keeps the panel off the critical path of the
first `Tab` entirely.

Stepping through an open, already visible session updates it in place. Commit and
cancel hide it immediately.

A ribbon nobody has touched for **10 seconds** hides itself. Interception makes the
failure it guards against concrete: a tap disabled by the system mid-gesture never
delivers the release of Command, so the session that would hide the panel never ends —
and a panel that ignored the mouse left the user nothing to click. The watchdog is
re-armed on every step and cancelled on hide, so it only ever fires on a session that
has stopped receiving events.

### Layout

The ribbon is measured against the system switcher rather than invented. Three
screenshots of the real thing on a 1728 pt display — at five, thirteen and twenty-five
applications — give the shape it has to match:

| applications | system icon | system gap | system panel |
|---|---|---|---|
| 5 | ~102 | ~31 | 41 % |
| 13 | ~97 | ~28 | 94 % |
| 25 | ~48 | ~17 | 96 % |

Three facts come out of that. The row **never wraps**: a crowded Space shrinks its icons
instead of growing a second line. The panel is **not a fixed share** of the screen — it
hugs its content and grows toward a ~96 % ceiling. And everything around the icon —
gap, padding, the room under it — stays **proportional to the icon**, which is why the
ribbon reads the same at three applications and at ten. Where we part company with the
system is the crowded end: it answers twenty-five applications by shrinking them to 48 pt,
which is a row of dots nobody can tell apart. We keep the icons legible and move the list
under them instead.

So the layout keeps exactly one free variable, the icon side, and derives the rest:

1. Gap is **30 %** of the icon, panel padding another 30 %, and the selected icon is drawn
   **20 %** larger than the rest.
2. The icon starts at **100 pt** and is the largest value whose row — gaps and paddings
   included — still fits 96 % of the screen width.
3. The ribbon holds at most **ten** slots: four entries before the selection, the
   selection, and five after it. Past ten applications it stops growing and becomes a
   window onto the list. Below ten it is as long as the Space is — the panel grows with
   the number of applications.
4. At every count the ribbon is a **carousel**: the selection keeps its slot and the
   icons turn under it. A step is therefore always the same distance for the eye,
   wherever in the list the user is, and the list has no ends — stepping past the last
   application brings the first one in from the right. A ribbon shorter than ten slots
   turns the same way, only with fewer icons: no application is ever shown twice, so with
   two applications there is nothing to the left of the selection. The selection's slot
   is the middle of what the ribbon holds — the first slot with two applications, the
   third with five — which is the fifth slot by the time the list fills the ribbon, and
   stays there from then on.

Measured on a 1728 pt-wide display:

| applications | icon | gap | panel width | slots |
|---|---|---|---|---|
| 1 | 100 | — | 9 % | 1 |
| 3 | 100 | 30 | 24 % | 3 |
| 5 | 100 | 30 | 39 % | 5 |
| 8 | 100 | 30 | 62 % | 8 |
| 10 | 100 | 30 | 77 % | 10 |
| 20 | 100 | 30 | 77 % | 10, windowed |
| 45 | 100 | 30 | 77 % | 10, windowed |
| 100 | 100 | 30 | 77 % | 10, windowed |

The icon now only shrinks where the screen makes it: a full ribbon needs 1330 pt, so
below roughly a 1390 pt-wide display the ten slots shrink to fit, down to a 16 pt floor.

That arithmetic lives in `CarouselWindow` — which entries the ten slots carry — and
`OverlayLayout` — where the slots are. Both take only numbers, import no AppKit, and are
unit-tested against every branch: fits, shrinks, freezes, wraps.

Only the **selected** application is named, under its icon, in semibold — the way the
system does it. Names under every icon were tried first and dropped: at twenty
applications they turn the ribbon into a wall of truncated text, and the one name the
user is reading is the one they are switching to. Because only one name is drawn, it is
free to be wider than its icon, up to the panel's own width. The name scales with the
icon — 13 pt at full size down to an 11 pt floor.

The box it is drawn in is only as wide as the name itself. A box of a fixed width has to
be pushed sideways to stay inside the panel whenever the icon is near an end of the
ribbon, and the name, centred in it, is pushed with it — so a name that had room to sit
on its icon ends up beside it instead. Measured against the system switcher, which
moves a name inwards only when the name itself does not fit, this is the difference
between a name that looks attached to its icon and one that looks misaligned. Sizing the
box to the text keeps the two identical: a name that fits stays centred on its icon
wherever the icon is, one that does not moves in by exactly what it takes to stay inside
the panel, and past that it is truncated.

Where it is truncated matters once window titles are switched on (S16). A title is as
long as the document someone opened, and its ends carry the meaning — the document at
the front, the application at the back — so it is cut in the **middle**. An earlier
ribbon capped the name at two and a half icons instead, which was too narrow to read at
one application and wide enough to sprawl under its neighbours at three; the panel's own
width is the only bound left.

The selection is marked by the icon itself rather than by a frame around it: it is drawn
at full strength and 20 % larger, and its neighbours are dimmed to 62 %. A white rounded
tile was tried first — it is what the system draws — and next to Liquid Glass it reads as
a second panel stacked on the first. Nothing else moves: the slots stay where they are,
so the enlargement is the only thing the eye has to follow.

The panel carries a 26 pt corner radius and, behind the row, a 15 % black scrim — the
least that keeps a white label readable when the desktop behind the glass is a white
window. Anything heavier is what made an earlier ribbon visibly darker than the original.

Its material is whichever one the system builds its own panels from. macOS 26 draws the
switcher in Liquid Glass, so where `NSGlassEffectView` exists the ribbon is made of it, in
the `regular` style: the `clear` style takes so much of what is behind it that over a flat
desktop the panel reads as nothing at all — the effect measurably disappeared. Below
macOS 26 the panel keeps the `.hudWindow` blur with a hairline white border, which is what
those systems render a HUD with. The choice is the system's version and nothing else: a
preference here would only offer the user a way to look less native than their own
machine. Both paths hand the same content view to the same panel, so the ribbon's
geometry and drawing know nothing about which one is underneath.

### A step is a slide, not a redraw

A carousel that jumped from one arrangement of icons to the next would give the eye
nothing to follow. So the ribbon is drawn where it lands, and its layer is slid in from
where it came: one `transform.translation.x` animation of 0.12 s on the content layer,
which the compositor runs without a second frame of drawing. The keystroke that triggers
it stays off that path entirely. Only a single step is animated — a jump of several slots,
a click on a distant icon, or a ribbon that did not move is drawn where it is, because a
slide that does not match the distance travelled is worse than none.

### Interception

The tap flips to `.intercept`, which is the first time the app needs **Accessibility**
rather than Input Monitoring. Two consequences, both handled here rather than in S10:

- If the grant is missing, `CGEvent.tapCreate` returns nil for a `.defaultTap`. The
  engine then retries once in `.observe` mode: an overlay that appears next to the
  system switcher is bad, but a dead `Cmd+Tab` is worse. The log records the fallback,
  and S10 turns it into something the user can see and fix.
- With the grant, our tap swallows `Cmd+Tab` before the system switcher sees it. The
  system HUD stops appearing, and the only switcher on screen is ours.

Swallowing is narrower than "drop what we consumed". A `flagsChanged` event is never
swallowed: Command going down and up is state every other application tracks, and eating
it leaves them believing the key is still held. A key-up is swallowed only when its
key-down was, so a `Tab` we let through cannot deliver half a keystroke to whoever is
frontmost. A listen-only tap placed behind ours confirms it: during a full gesture it
saw the two `flagsChanged` events and no `Tab` at all.

## Definition of Done

- [ ] An overlay appears on the current Space while a session is open, and disappears on commit and on cancel.
- [ ] Showing it does not change which application is frontmost, and the panel is never key or main.
- [ ] A press-and-release `Cmd+Tab` faster than the delay shows nothing at all.
- [ ] The overlay lists exactly the applications of the S05 snapshot, in the same order, with the selected one highlighted and named under its icon.
- [ ] The panel is never wider than 96 % of the screen, never wraps, and its geometry matches the measured system switcher within a couple of points while both show the same row.
- [ ] The ribbon turns under a stationary selection at any count, never showing an application twice, and past ten applications it stops growing with the selection in the fifth slot.
- [ ] A session that stops receiving events hides itself instead of stranding the panel.
- [ ] Interception never swallows a modifier change, and never swallows a key-up whose key-down went through.
- [ ] Layout and carousel arithmetic is pure and unit-tested: fits, shrinks, freezes, wraps.
- [ ] The name of the selected application is centred on its icon wherever the icon sits in the ribbon, and moves inwards only when it would otherwise leave the panel.
- [ ] On macOS 26 the panel is Liquid Glass in the `regular` style, visibly frosted over any desktop; below it, the HUD blur.
- [ ] The selected icon is 20 % larger and at full strength, its neighbours dimmed, with no tile drawn behind anything.
- [ ] A name longer than the panel is truncated in the middle, keeping both ends of the title.
- [ ] A single step slides the ribbon; a jump does not.
- [ ] With Accessibility granted the tap intercepts: the system switcher does not appear.
- [ ] Without it the engine falls back to `.observe` and logs the fallback instead of dying.
- [ ] The whole suite is green; `swift-format --strict` and `swiftlint --strict` are clean.
- [ ] The Release bundle still declares zero entitlements and links no non-system library.

## Test cases

| # | Case | Expected |
|---|------|----------|
| 1 | layout, three icons on a wide screen | one row, full icon size |
| 2 | layout, a row wider than the budget | icon side shrinks, still one row |
| 3 | layout, more applications than the window holds | icon frozen, panel frozen, ten slots |
| 4 | layout, a single icon | one slot, no negative gaps |
| 5 | layout, zero icons | zero size, no slots |
| 5a | layout, any non-empty count | panel width never exceeds 96 % of the screen |
| 5b | layout, any count | gap and padding stay the configured shares of the icon |
| 5c | layout, any count | the row never wraps |
| 5d | layout, slots | a slot holds the icon and the room its name needs |
| 5e | layout, the measured counts | icon and gap match the system switcher table |
| 5f | layout, label size | full size when roomy, smaller when crowded, never below the floor |
| 5g | layout, any count | every slot is inside the panel |
| 5h | layout, any count on four display widths | slots never overlap, the width budget holds |
| 5i | carousel, ten applications or fewer | every entry shown once, turning under the selection |
| 5j | carousel, more than ten | ten entries, the selection in the fifth slot |
| 5k | carousel, a step across either end | the window wraps, no duplicates, always full |
| 5l | carousel, the selection's slot from one to ten entries | the middle of the ribbon, then the fifth slot from ten on |
| 5m | carousel, an empty list | no entries |
| 5n | slide, one step either way, at any count | one slot of travel; a jump, an unmoved ribbon or a changed shape, none |
| 5o | name area, a name that fits, at either end of the ribbon | centred on its icon |
| 5p | name area, a name too wide for the first slot | moved in to the panel's inset, no further |
| 5q | name area, a name too wide for the last slot | stops at the far inset |
| 5r | name area, a name past the panel | capped at the panel's inset, truncated in the middle |
| 5s | name area, any name | sits directly under its icon, one label high |
| 5t | backdrop, the running system | the content view is inside whichever material the system provides |
| 6 | controller, session opens | show is scheduled, nothing visible yet |
| 7 | controller, commit before the delay | nothing was ever shown |
| 8 | controller, delay elapses with the session open | the panel is shown once |
| 9 | controller, step while visible | contents updated, not re-shown |
| 10 | controller, cancel while visible | hidden, and a pending schedule is dropped |
| 11 | controller, second session after a commit | scheduled again from scratch |
| 12 | engine, `.intercept` unavailable | falls back to `.observe`, logs it, reports running |
| 13 | controller, no event for the idle limit | the panel hides itself |
| 14 | controller, a step before the limit | the watchdog is re-armed, nothing hides |
| 15 | swallow policy, `flagsChanged` under `.intercept` | passes through |
| 16 | swallow policy, key-up whose key-down passed through | passes through |

## Manual runbook

1. Build and launch the Release bundle; grant Accessibility; relaunch.
2. Hold Command and press Tab → expected: our overlay appears with the applications of
   the current Space, the system switcher does not appear at all.
3. Release quickly without holding → expected: the switch happens with no HUD flash.
4. Move to another Space with different applications and repeat → expected: the overlay
   lists that Space's applications.
5. Revoke Accessibility, relaunch → expected: the app still runs, the log shows the
   `.observe` fallback, and `Cmd+Tab` still works through the system switcher.
6. Switch while a full-screen application is in front → expected: the overlay is visible
   above it.
7. While the overlay is up, type into another application after the gesture ends →
   expected: keystrokes land normally, no modifier is stuck down.
8. On a Space with more than a dozen applications, hold Command and step through the whole
   list → expected: ten icons at a time, the selection always in the fifth slot, the icons
   sliding under it by one per step, and stepping past the last application brings the
   first one back without a jump.
8a. On a Space with three or four applications → expected: the ribbon is as long as the
   Space is, the selection holds its slot, the icons turn under it, and no application is
   shown twice.
8b. Step to the first icon and to the last → expected: the name sits under its own icon,
   not beside it, and never leaves the panel.
8c. Switch on window titles (S16) and select a window with a very long title → expected:
   the name is cut in the middle, with the start of the title and the application's name
   at the end both still readable.
9. Put the ribbon over a busy window, over a flat white window and over a plain wallpaper →
   expected: on macOS 26 the panel is visibly frosted glass in every case — never an
   invisible rectangle; below 26 it is the HUD blur.

## Risks and open questions

- **The panel on a full-screen Space.** `.fullScreenAuxiliary` is the documented way in;
  runbook step 6 is the check.
- **Multi-display.** The overlay goes to `NSScreen.main` — the screen with keyboard
  focus, not the one with the mouse. That is a preference (S08); until then it is a
  documented choice, not an accident.
- **The 120 ms delay is a guess.** It matches the feel of the system switcher on this
  machine; if it turns out to be visibly wrong it becomes a preference in S08.
- **The ten-slot window is a judgement call.** Four before and five after the selection is
  what fits at full icon size on a laptop display without the ribbon dominating the screen.
  On a much wider display it could afford more; if that reads badly it becomes a share of
  the screen width rather than a count.
- **A short ribbon turns rather than holds still.** It keeps one mechanic at every count,
  at the price of icons that move on a Space with three applications where a fixed row
  would have been calm. The alternative — standing still below ten and spinning above —
  was tried and read as two different switchers; runbook step 8a is the check.
- **Interception makes bugs expensive.** A wedged session now means a swallowed
  `Cmd+Tab`. The tap's re-arm already cancels an open session (S05); with an overlay on
  screen a wedge is at least visible.
