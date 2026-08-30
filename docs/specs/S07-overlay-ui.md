# S07 — Overlay UI

**Status:** agreed · **Depends on:** S01, S04, S05, S06 · **ADRs:** —

## Goal

Show the user what they are switching to, and finally take over the shortcut: the
tap moves to `.intercept`, the system switcher stops appearing, and ours appears
instead — with the applications of the current Space only, which is the whole point
of the product.

## Non-goals

- Window previews. Never, in any release: they need Screen Recording (S00).
- Mouse interaction — hovering and clicking a tile is S08 together with preferences.
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
| `ignoresMouseEvents` | `true` | S07 has no mouse interaction; clicks must reach the application underneath |
| `hidesOnDeactivate` | `false` | we are never active to begin with |
| `backgroundColor` | `.clear`, with a `.hudWindow` visual-effect view and a 20 pt corner radius | native HUD look, no custom chrome |

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
and a panel that ignores the mouse leaves the user nothing to click. The watchdog is
re-armed on every step and cancelled on hide, so it only ever fires on a session that
has stopped receiving events.

### Layout

The ribbon is dynamic in both directions and is meant to read as the system switcher
does, only with the applications of the current Space.

Every tile is an icon with the application's **name underneath it** — all of them, not
only the selected one, which is the one deliberate departure from the original. The
selected tile carries a rounded highlight, its icon is drawn 12 % larger, and its name is
semibold and brighter; the others stay regular and dimmed. Tile slots are uniform and
already sized for the enlarged icon, so moving the selection never shifts the row.

Sizing is a pure function of the application count and the screen size:

1. The icon side starts at **128 pt** — the size the system uses — and shrinks toward a
   **48 pt** floor while the row still has to fit 90 % of the screen width.
2. If the row does not fit even at the floor, it wraps into balanced rows
   (`ceil(count / rows)` tiles per row, each row centred) and the panel grows in height.
3. The gaps then **grow** — up to 15 pt — so the ribbon reaches a target of 80 % of the
   screen width instead of leaving a wide, half-empty panel. The cap keeps tiles close
   together the way the original does; without it a handful of applications drift apart
   across a stretched panel.
4. When even the largest icons and the widest gaps cannot reach the target, the panel
   hugs its content rather than stretching around it. Three applications produce a
   compact ribbon, not a wide slab with three icons floating in the middle — the same
   thing the system switcher does.

Measured on a 1728 pt-wide display:

| applications | icon | gap | rows | panel width |
|---|---|---|---|---|
| 3 | 128 | 15 | 1 | 30 % |
| 6 | 128 | 15 | 1 | 61 % |
| 10 | 119 | 4 | 1 | 89 % |
| 16 | 68 | 4 | 1 | 90 % |
| 24 | 48 | 15 | 2 | 59 % |
| 40 | 48 | 4 | 2 | 87 % |

Height has a budget too: the ribbon may take **80 %** of the screen height, and when the
wrapped rows overflow it the icon shrinks past the 48 pt floor — in 4 pt steps down to a
**16 pt** minimum — until they fit. On a 1280 × 800 display that means 60 applications at
48 pt over 4 rows (384 pt), 121 at 36 pt over 7 rows (565 pt) and 154 at 32 pt over 8
rows (612 pt) against a 640 pt budget. Only past roughly 380 applications does the 16 pt
minimum stop the budget from binding and the ribbon exceed it — a capacity limit worth
naming rather than hiding, and one no single Space reaches.

That arithmetic lives in `OverlayLayout`, takes only numbers, imports no AppKit, and is
unit-tested against every branch: fits, shrinks, wraps, fills, hugs, and both budgets.

Spacing is deliberately tight, the way the original is: 8 pt around the icon inside its
tile, 10 pt from the ribbon to the panel edge, 2 pt between an icon and its name. The
name scales with the icon — 13 pt at full size down to a 9 pt floor at the smallest —
so a crowded ribbon shrinks as a whole instead of growing a band of oversized text.

The look copies the original: a dark `.hudWindow` blur under a 28 % black tint, a 24 pt
corner radius, a hairline white border, and a 22 % white rounded highlight behind the
selected tile.

Only the selection changes between the steps of a session, so a step is not a repaint of
the ribbon. The geometry is computed once per session and reused; the view invalidates
the tile that lost the selection and the tile that gained it, and draws only the slots
that intersect the dirty rectangle. The content view is layer-backed so that AppKit
clears the dirty rectangle before `draw(_:)`, which is what keeps the translucent tint
from stacking on the two repainted tiles.

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
- [ ] The overlay lists exactly the applications of the S05 snapshot, in the same order, each named under its icon, the selected one enlarged and bold.
- [ ] The panel is never wider than 90 % of the screen and never taller than 80 % of it until the icon floor is reached; its height follows the number of rows.
- [ ] A session that stops receiving events hides itself instead of stranding the panel.
- [ ] Interception never swallows a modifier change, and never swallows a key-up whose key-down went through.
- [ ] Layout arithmetic is pure and unit-tested: fits, shrinks, wraps, fills, hugs.
- [ ] With Accessibility granted the tap intercepts: the system switcher does not appear.
- [ ] Without it the engine falls back to `.observe` and logs the fallback instead of dying.
- [ ] The whole suite is green; `swift-format --strict` and `swiftlint --strict` are clean.
- [ ] The Release bundle still declares zero entitlements and links no non-system library.

## Test cases

| # | Case | Expected |
|---|------|----------|
| 1 | layout, three icons on a wide screen | one row, full icon size |
| 2 | layout, a row wider than the budget | icon side shrinks, still one row |
| 3 | layout, more icons than fit even at the floor size | wraps into balanced rows, floor size kept |
| 4 | layout, a single icon | one row, no negative gaps |
| 5 | layout, zero icons | zero size, no rows |
| 5a | layout, any non-empty count | panel width never exceeds 90 % of the screen |
| 5b | layout, a handful of applications | gaps grow so the ribbon fills the target width |
| 5c | layout, a row that only just fits | gaps stay at the minimum |
| 5e | layout, any count | no gap exceeds the 15 pt cap |
| 5f | layout, label size | full size when roomy, smaller when crowded, never below the floor |
| 5d | layout, slots | slot width already fits the enlarged selected icon |
| 5g | layout, a count whose rows overflow the height | icon shrinks past the floor until both budgets hold |
| 5h | layout, any count on four display widths | slots never overlap, both budgets hold |
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

## Risks and open questions

- **The panel on a full-screen Space.** `.fullScreenAuxiliary` is the documented way in;
  runbook step 6 is the check.
- **Multi-display.** The overlay goes to `NSScreen.main` — the screen with keyboard
  focus, not the one with the mouse. That is a preference (S08); until then it is a
  documented choice, not an accident.
- **The 120 ms delay is a guess.** It matches the feel of the system switcher on this
  machine; if it turns out to be visibly wrong it becomes a preference in S08.
- **Names under every icon** are a departure from the original, asked for deliberately.
  With many applications they truncate to the tile width; if that reads badly at the 48 pt
  floor, dropping them for the smallest sizes is the fallback.
- **Interception makes bugs expensive.** A wedged session now means a swallowed
  `Cmd+Tab`. The tap's re-arm already cancels an open session (S05); with an overlay on
  screen a wedge is at least visible.
