# S02 — Application and window inventory

**Status:** agreed · **Depends on:** [S00](S00-threat-model.md), [S01](S01-architecture.md)

## Goal

A pure, testable answer to the question the switcher asks on every keypress: *which
applications exist right now, and what windows does each of them have?* Space membership
is **not** decided here — S03 consumes this inventory and adds it.

## Non-goals

- No ordering by recency. The inventory is ordered deterministically; MRU is S05.
- No window titles. Reading `kCGWindowName` would require Screen Recording, which S00
  forbids outright. The guard from S01 is extended to enforce that.
- No activation. Raising an application is S06.

## Design

### The unit is the application

An application is the switchable entity; its windows are an attribute of it. Windows are
carried because S03 needs them to decide which Space an application is on, and because
S12+ adds per-window switching without reshaping the model.

### Snapshot, not cache

Nothing is kept between keypresses. On each press the inventory is built from two calls:
`NSWorkspace.runningApplications` for identity, and one `CGWindowListCopyWindowInfo` for
windows. Zero memory at rest, zero cache invalidation, and no stale list — the whole cost
sits in the press itself, which S04 must keep inside the event tap's budget.

### Types

`SwitcherCore` owns the model and the rules; nothing here imports a system framework.

```
ProcessIdentifier      wrapper over pid_t
WindowIdentifier       wrapper over CGWindowID
ActivationPolicy       regular | accessory | prohibited
WindowVisibility       onScreen | minimised | hiddenApplication
RunningApplication     pid, bundleIdentifier?, name, policy, isHidden, isActive
WindowInfo             id, ownerPID, layer, alpha, isOnScreen
SwitchableApplication  pid, bundleIdentifier?, name, isActive, windows
ApplicationWindow      id, visibility
ApplicationInventory   pure builder: ([RunningApplication], [WindowInfo], own pid) -> [SwitchableApplication]
```

`RunningApplication` and `WindowInfo` are the raw shapes the ports return; the two
`Switchable*` types are what the rest of the app consumes.

### Rules

An application is switchable when its activation policy is `.regular`. That is exactly
what the stock `Cmd+Tab` shows, it is one rule a user can be told, and it keeps an
application that has just launched or closed its last window from vanishing mid-cycle.
Accessory applications and background agents never appear. The switcher excludes itself
by process identifier, passed in by the composition root.

A window belongs to an application when it is on layer `0` (the normal window layer,
which drops menus, tooltips, the Dock and the wallpaper) and its alpha is greater than
zero. Everything else is discarded before the inventory is built.

Visibility is derived, not read: a window reported as on-screen is `onScreen`; otherwise
it is `hiddenApplication` when its owning application is hidden, and `minimised` when it
is not. The distinction matters because `Cmd+H` and `Cmd+M` behave differently in macOS
and S03 treats their Space membership differently.

Applications are ordered by localised name, case-insensitively, with the process
identifier as the tie-break. Deterministic order is what makes the builder testable; the
useful order is MRU and arrives in S05. Windows keep the order the window source gave
them, which is front-to-back z-order — S03 and S06 both need it, and re-sorting would
throw away information the system already computed.

## Definition of Done

- [x] `ApplicationInventory` is a pure function over its three inputs, with no system import.
- [x] `ApplicationSource` and `WindowSource` ports exist; the adapters are thin.
- [x] The window source asks for all windows, including off-screen ones, so minimised
      windows survive into the model.
- [x] `kCGWindowName` and `AXTitle` are in the forbidden-API guard and the sources never
      read titles. Amended by S16: `AXTitle` needs Accessibility and not Screen Recording,
      so it stays in the guard with one allowlisted file, and only the window mode of S16
      reads a title.
- [x] The menu bar item can copy an inventory summary to the pasteboard, so the model can
      be inspected without a UI and without putting any of it in the log.
- [ ] The inventory of a real machine matches what the stock `Cmd+Tab` shows, checked by
      the runbook.

## Test cases

| # | Case | Expected |
|---|------|----------|
| 1 | An accessory application with windows | excluded |
| 2 | A prohibited (background) application | excluded |
| 3 | A regular application with no windows | included, empty window list |
| 4 | The switcher's own process | excluded |
| 5 | A window on a layer other than zero | dropped |
| 6 | A window with alpha zero | dropped |
| 7 | An off-screen window of a visible application | `minimised` |
| 8 | An off-screen window of a hidden application | `hiddenApplication` |
| 9 | An on-screen window of a hidden application | `onScreen` |
| 10 | Windows of an unknown process identifier | dropped, no phantom application |
| 11 | Two applications with the same name | ordered by process identifier |
| 12 | Mixed-case names | ordered case-insensitively |
| 13 | An application whose every window was dropped | still included, empty window list |

## Manual runbook

1. Open several applications, minimise one, hide another with `Cmd+H`, leave one with no
   windows open.
2. Menu bar icon → **Copy Inventory**, then paste anywhere.
3. The pasted list names exactly the applications the stock `Cmd+Tab` overlay lists —
   same set, no accessory utilities, no Humane Space Tab itself.
4. The minimised window is counted as `minimised`, the hidden application's windows as
   `hidden`. Until S03 lands, windows living on another Space are also counted as
   minimised; that is the known approximation, not a defect.
5. `/usr/bin/log show --last 5m --info --debug --style compact
   --predicate 'subsystem == "io.github.n0sfer666.humane-space-tab"'`
   → `inventory summary copied to the pasteboard` and nothing else: no name, no count,
   no title ever reaches the log.
6. No permission prompt appears at any point: the inventory needs none.

## Risks and open questions

- **`CGWindowListCopyWindowInfo` without Screen Recording** returns window geometry and
  ownership but no titles. That is the trade S00 already made.
- **Off-screen is not the same as minimised.** Measured on a live machine: of 177 windows
  returned for the whole session, 152 were off-screen — most of them not minimised at all
  but simply living on another Space or belonging to a helper layer. That is precisely
  what S03 disentangles; until then the `minimised` flag over-reports.
- **Open:** whether tabbed windows (one window, many tabs) need their own representation.
  Deferred to S12+, where per-window switching makes the question real.
