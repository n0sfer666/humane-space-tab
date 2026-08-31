# S16 — Windows of one application

**Status:** agreed · **Depends on:** S02, S03, S05, S06, S07, S08 · **ADRs:** —

## Goal

`Cmd+Tab` cycles applications, which is the macOS model. Users who came from Windows or
Linux expect it to cycle **windows**: two documents of the same editor are two entries, not
one. S08 already defines the preference — `WindowSwitchingEnabled`, off by default. S16 is
the behaviour behind it: what the ribbon lists, in what order, what it says, and how a
single window is raised.

## Non-goals

- **Changing the default.** Off means the app behaves exactly as it does today, and no
  Accessibility call this spec adds is ever made.
- **Window previews.** They need Screen Recording, which S00 forbids for good (S07).
- **A second hotkey for windows-of-the-front-app.** `Cmd+~` stays S12+; this spec has one
  list, not two.
- **Reading anything from a window but its title, position and size.** No contents, no
  document paths, no `AXValue` of anything.

## What this spec revises

Two earlier decisions were made on premises that no longer hold, and they are corrected
here rather than left as contradictions:

- **S02 forbids `AXTitle` "because it would require Screen Recording".** That is true of
  `kCGWindowName` and false of `AXTitle`: an accessibility client reads window titles with
  the Accessibility grant this app already holds. The ban was resting on a wrong reason.
  The forbidden-API guard keeps the symbol, and allowlists exactly one file, the way it
  already does for `SkyLightShim.swift`.
- **S06 rejected `kAXRaiseAction` because it "needs a grant we do not need yet".** Since
  S07 the app holds that grant for interception, and raising one window has no public
  alternative — `NSRunningApplication.activate()` raises an application. Applications are
  still raised the S06 way; only the window case uses AX.

## Design

### The unit becomes the window

With the preference on, the S03 filter output is expanded: every window of every switchable
application on the current Space is its own entry, carrying its application's icon, its
application's name, and its own title. An application with one window looks exactly as it
does today, which is what most of the ribbon will be.

An application whose windows are all off the current Space keeps its single entry — it is
still switchable and the user still expects it there. It is listed as the application, with
no title, and activating it activates the application (S06). The list therefore never has
fewer entries than the application list does.

### Order is the z-order, not a second history

S05 seeds application order from the front-to-back on-screen list and maintains it from
activation notifications, because an application's recency cannot be read back later. A
window's can: `CGWindowListCopyWindowInfo(.optionOnScreenOnly)` **is** the live stacking
order, and stacking is what "most recently used" means for a window. Clicking a second
window of the same application raises it and fires no activation notification, so a
maintained window history would be wrong within a second of the user touching the mouse;
the z-order cannot be.

So window mode keeps no order state at all. The session reads the front-to-back list when
it opens, and windows that are not in it — minimised, or belonging to a hidden application —
are appended after it in inventory order, exactly as S05 appends applications the seed
cannot see.

This is the second window-server call inside the tap callback, next to the `.optionAll`
snapshot. S05 budgets one frame for the whole session build, measured at 2.7 ms median;
the added call must be measured against that budget, and the measurement belongs in this
spec's DoD, not in a hope.

### Titles arrive late, on purpose

`AXUIElementCopyAttributeValue` is synchronous IPC into another process. A busy or wedged
application answers slowly or not at all, and an event tap that spends about a second in
its callback is disabled by the window server — the exact failure S04 is built to avoid.
Titles are therefore never read on the critical path:

1. The session opens with icons and application names. The ribbon is on screen.
2. Titles are fetched afterwards, off the tap callback, with
   `AXUIElementSetMessagingTimeout` set low (50 ms) so one wedged application cannot stall
   the rest.
3. Each answer updates the entry it belongs to; the panel redraws the label only when the
   entry it is showing is the one that changed.

An application that never answers keeps its application name as its label. Degradation is a
missing title, never a missing entry and never a stalled gesture.

### Matching an AX window to a CG window

AX has no public way to name a `CGWindowID`; `_AXUIElementGetWindow` is private and S00
keeps the private layer to the single S03 shim. The public match is the frame: for each
process, its AX windows and its CG windows are paired by identical position and size, which
the window server and the accessibility API both report in screen coordinates.

Two windows of one application with the same frame to the pixel are indistinguishable this
way. They are then paired by their order in each list, and if that is still ambiguous the
title is dropped for both — a wrong title on a window is worse than none, because the user
would switch to the wrong one deliberately.

### Raising one window

Three calls, in this order, all on the AX element the match found:

1. `kAXMinimizedAttribute = false`, if the window is minimised — otherwise the raise lands
   on a window in the Dock.
2. `AXUIElementPerformAction(kAXRaiseAction)` — brings the window to the front of its own
   application.
3. `NSRunningApplication.activate()` — gives the application the focus, exactly as S06.

The application case is untouched: an entry that names an application and not a window is
activated with `activate()` alone, and S06's failure rule stands — if the target is gone,
nothing is activated and nothing else is chosen in its place.

### Permissions decide the mode, not the preference alone

Window mode needs Accessibility for both the title and the raise. The app already refuses
to switch at all without it (S10, S15), so there is no new permission and no new prompt:
when the permission state is anything but `intercepting`, the switcher is idle and the
preference is moot. Nothing in this spec asks for a grant, and nothing in it is reachable
with the preference off.

### Privacy

A window title can carry a document name, a chat partner, a URL. It is read to be drawn and
for nothing else:

- Titles live in the session snapshot, which S05 discards when the gesture ends.
- Nothing writes a title to the log, at any level. S00's rule — key codes, application
  names and window titles are never logged — is unchanged and now has an enforced case.
- Nothing persists a title. There is no window MRU file to write one into, by design.

## Definition of Done

- [ ] With `WindowSwitchingEnabled` off, no AX window call is made and the ribbon is
      byte-identical to today's.
- [ ] With it on, every window of every switchable application on the current Space is its
      own entry, ordered front to back, minimised and hidden ones appended.
- [ ] An application with no window on the current Space stays in the list as an
      application.
- [ ] The selected entry is labelled with its window title; an application that does not
      answer is labelled with its application name instead.
- [ ] No title is read inside the tap callback, and the session build stays inside the S05
      frame budget — measured, with the number written into this spec.
- [ ] Committing a window entry raises that window, un-minimising it first, and activates
      its application.
- [ ] `AXTitle` stays in the forbidden-API guard, allowlisted in exactly one file.
- [ ] No title reaches the log at any level; the log line for a window commit names no
      window.
- [ ] The whole suite is green; `swift-format --strict` and `swiftlint --strict` are clean.
- [ ] The Release bundle still declares zero entitlements and links no non-system library.

## Test cases

| # | Case | Expected |
|---|------|----------|
| 1 | expansion, preference off | the application list, unchanged |
| 2 | expansion, one app with three windows | three entries, one icon repeated |
| 3 | expansion, app with no window on this Space | one entry, the application |
| 4 | expansion, minimised window | present, after the on-screen ones |
| 5 | order, three windows front to back | the ribbon's order is the stacking order |
| 6 | order, windows outside the on-screen list | appended in inventory order |
| 7 | matching, one AX window and one CG window | paired |
| 8 | matching, two windows, distinct frames | paired by frame, not by order |
| 9 | matching, two windows, identical frames | paired by index |
| 10 | matching, ambiguity that index cannot break | no title on either |
| 11 | titles, an application that times out | its entries keep the application name |
| 12 | titles, an answer arriving after the session ended | dropped, no redraw |
| 13 | commit, a window entry | un-minimise, raise, activate, in that order |
| 14 | commit, an application entry | activate only, no AX call |
| 15 | commit, a window whose application quit | reported as a failure, nothing else raised |
| 16 | log, a window commit | the line names no window |

## Manual runbook

1. Open two Finder windows and one editor window on one Space, `defaults write
   io.github.n0sfer666.humane-space-tab WindowSwitchingEnabled -bool true`, reopen the
   switcher → expected: three entries, two of them Finder.
2. Hold `Cmd`, `Tab` to the second Finder window, release → expected: that window comes
   forward, not the other one.
3. Minimise a window and reopen the switcher → expected: it is still listed, last; choosing
   it restores and focuses it.
4. Switch to an application with a slow or beachballed window → expected: the ribbon opens
   immediately with icons; the label is the application name until the title arrives.
5. Turn the preference off, reopen → expected: the ribbon lists applications again, and
   `log show --predicate 'subsystem == "io.github.n0sfer666.humane-space-tab"'` contains no
   window title anywhere in the session.

## Risks and open questions

- **The frame match is a heuristic.** Tabbed windows, sheets and full-screen transitions can
  make two frames equal for a moment. The fallback is a missing title, never a wrong one,
  and never a missing entry.
- **AX cost is another process's problem.** The timeout bounds it, but a machine full of
  slow applications will fill labels visibly late. That is the price of not blocking the
  gesture, and the ribbon is usable without a single title.
- **Many windows make a long ribbon.** S07 already shrinks icons and scrolls the ribbon;
  twenty windows will look crowded in a way twenty applications rarely do. If it turns out
  unusable, the answer is a ribbon change in S07, not a different order here.
