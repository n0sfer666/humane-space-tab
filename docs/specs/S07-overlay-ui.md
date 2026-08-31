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
ribbon reads the same at five applications and at twenty-five.

So the layout keeps exactly one free variable, the icon side, and derives the rest:

1. Gap is **30 %** of the icon, panel padding another 30 %, the selected tile's inset 8 %.
2. The icon starts at **100 pt** and is the largest value whose row — gaps and paddings
   included — still fits 96 % of the screen width.
3. Past **25 applications** the icon stops shrinking: the panel freezes at its 25-slot
   width and the ribbon **scrolls** instead. Beyond that, shrinking further would trade a
   readable ribbon for a row of unrecognisable dots.
4. Scrolling moves by the smallest amount that keeps the selection visible: the ribbon
   stays put while the selection is inside the window and slides one slot when it steps
   past an edge, so cycling through a crowded Space does not slide the icons under the
   eye. It starts each session at the beginning.

Measured on a 1728 pt-wide display, against the numbers above:

| applications | icon | gap | panel width | visible |
|---|---|---|---|---|
| 3 | 100 | 30 | 24 % | 3 |
| 5 | 100 | 30 | 39 % | 5 |
| 8 | 100 | 30 | 61 % | 8 |
| 13 | 96 | 29 | 95 % | 13 |
| 20 | 62 | 19 | 94 % | 20 |
| 25 | 50 | 15 | 94 % | 25 |
| 34 | 50 | 15 | 94 % | 25, scrolled |

That arithmetic lives in `OverlayLayout` and `RibbonScroll`, takes only numbers, imports
no AppKit, and is unit-tested against every branch: fits, shrinks, freezes, scrolls.

Only the **selected** application is named, under its icon, in semibold — the way the
system does it. Names under every icon were tried first and dropped: at twenty-five
applications they turn the ribbon into a wall of truncated text, and the one name the
user is reading is the one they are switching to. Because only one name is drawn, it is
free to be wider than its icon — up to two and a half times as wide, and never wider
than the panel's own padding allows. The name scales with the icon — 13 pt at full size
down to an 11 pt floor.

The box it is drawn in is only as wide as the name itself. A box of a fixed width has to
be pushed sideways to stay inside the panel whenever the icon is near an end of the
ribbon, and the name, centred in it, is pushed with it — so a name that had room to sit
on its icon ends up beside it instead. Measured against the system switcher, which
moves a name inwards only when the name itself does not fit, this is the difference
between a name that looks attached to its icon and one that looks misaligned. Sizing the
box to the text keeps the two identical: a name that fits stays centred on its icon
wherever the icon is, one that does not moves in by exactly what it takes to stay inside
the panel, and past that it is truncated with an ellipsis.

The selected icon is not enlarged, which is also what the system does: it carries a 22 %
white rounded highlight drawn around it, and the row stays perfectly still as the
selection moves. The panel itself carries no tint of our own — the tint we used to paint
made our ribbon visibly darker than the original — and a 26 pt corner radius.

Its material is whichever one the system builds its own panels from. macOS 26 draws the
switcher in Liquid Glass, so where `NSGlassEffectView` exists the ribbon is made of it;
below that the panel keeps the `.hudWindow` blur with a hairline white border, which is
what those systems render a HUD with. The choice is the system's version and nothing
else: a preference here would only offer the user a way to look less native than their
own machine. Both paths hand the same content view to the same panel, so the ribbon's
geometry and drawing know nothing about which one is underneath.

Only the selection changes between the steps of a session, so a step is not a repaint of
the ribbon. The geometry is computed once per session and reused; the view invalidates
the tile that lost the selection and the tile that gained it — grown by the room the
highlight and the name take outside their slot — and draws only the slots that intersect
the dirty rectangle. The content view is layer-backed and masks its bounds, which both
clears the dirty rectangle before `draw(_:)` and clips the slots that have scrolled past
the panel's edge.

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
- [ ] The panel is never wider than 96 % of the screen, never wraps, and its geometry matches the measured system switcher within a couple of points.
- [ ] Past 25 applications the icon stops shrinking and the ribbon scrolls, always keeping the selection visible.
- [ ] A session that stops receiving events hides itself instead of stranding the panel.
- [ ] Interception never swallows a modifier change, and never swallows a key-up whose key-down went through.
- [ ] Layout and scroll arithmetic is pure and unit-tested: fits, shrinks, freezes, scrolls.
- [ ] The name of the selected application is centred on its icon wherever the icon sits in the ribbon, and moves inwards only when it would otherwise leave the panel.
- [ ] On macOS 26 the panel is Liquid Glass; below it, the HUD blur.
- [ ] With Accessibility granted the tap intercepts: the system switcher does not appear.
- [ ] Without it the engine falls back to `.observe` and logs the fallback instead of dying.
- [ ] The whole suite is green; `swift-format --strict` and `swiftlint --strict` are clean.
- [ ] The Release bundle still declares zero entitlements and links no non-system library.

## Test cases

| # | Case | Expected |
|---|------|----------|
| 1 | layout, three icons on a wide screen | one row, full icon size |
| 2 | layout, a row wider than the budget | icon side shrinks, still one row |
| 3 | layout, more applications than the visible limit | icon frozen, panel frozen, ribbon scrolls |
| 4 | layout, a single icon | one slot, no negative gaps |
| 5 | layout, zero icons | zero size, no slots |
| 5a | layout, any non-empty count | panel width never exceeds 96 % of the screen |
| 5b | layout, any count | gap and padding stay the configured shares of the icon |
| 5c | layout, any count | the row never wraps |
| 5d | layout, slots | a slot holds the icon and the room its name needs |
| 5e | layout, the measured counts | icon and gap match the system switcher table |
| 5f | layout, label size | full size when roomy, smaller when crowded, never below the floor |
| 5g | layout, past the limit | hidden slots sit outside the panel |
| 5h | layout, any count on four display widths | slots never overlap, the width budget holds |
| 5i | scroll, everything visible | never scrolls |
| 5j | scroll, selection inside the window | offset unchanged |
| 5k | scroll, selection steps past an edge | offset moves by one, either way |
| 5l | scroll, wrap to the first application | offset returns home |
| 5m | scroll, a shorter ribbon | a stale offset is clamped back into range |
| 5n | name area, a name that fits, at either end of the ribbon | centred on its icon |
| 5o | name area, a name too wide for the first slot | moved in to the panel's inset, no further |
| 5p | name area, a name too wide for the last slot | stops at the far inset |
| 5q | name area, a name past the budget | capped at two and a half icons, truncated |
| 5r | name area, any name | sits directly under its icon, one label high |
| 5s | backdrop, the running system | the content view is inside whichever material the system provides |
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
8. On a Space with more than a dozen applications, step to the first icon and to the last
   → expected: the name sits under its own icon, not beside it, and never leaves the
   panel.
9. Put the ribbon over a busy window or wallpaper → expected: on macOS 26 the panel is
   glass — the picture behind it bends at the panel's edge; below 26 it is the HUD blur.

## Risks and open questions

- **The panel on a full-screen Space.** `.fullScreenAuxiliary` is the documented way in;
  runbook step 6 is the check.
- **Multi-display.** The overlay goes to `NSScreen.main` — the screen with keyboard
  focus, not the one with the mouse. That is a preference (S08); until then it is a
  documented choice, not an accident.
- **The 120 ms delay is a guess.** It matches the feel of the system switcher on this
  machine; if it turns out to be visibly wrong it becomes a preference in S08.
- **The 25-application limit is a judgement call.** It is where the system switcher's own
  icons land at about 48 pt on a 1728 pt display; on a much wider display the ribbon could
  afford more before scrolling. If that reads badly it becomes a share of the screen width
  rather than a count.
- **Interception makes bugs expensive.** A wedged session now means a swallowed
  `Cmd+Tab`. The tap's re-arm already cancels an open session (S05); with an overlay on
  screen a wedge is at least visible.
