# S03 — Space attribution

**Status:** agreed · **Depends on:** [S00](S00-threat-model.md), [S02](S02-inventory.md)

## Goal

Decide which applications from the S02 inventory belong to the **current Space**. This is
the feature the whole project exists for: the switcher must not offer an application that
lives on another desktop.

## Non-goals

- No Space switching. Moving the user between Spaces is S06's problem, and mostly the
  system's.
- No naming or enumerating Spaces in the UI. The only Space that matters is the current one.
- No per-display Space model yet. Multi-display is S07's concern; here a window is either
  on the current Space or not.

## What the system actually reports

Measured on a live machine with two Spaces (`docs/specs/` probes, macOS 15):

| Source | Result |
|---|---|
| `CGWindowListCopyWindowInfo(.optionOnScreenOnly)`, layer 0 | 15 windows — the current Space, minus everything minimised |
| `CGWindowListCopyWindowInfo(.optionAll)`, layer 0 | 121 windows — every Space, every helper process, minimised included |
| `SLSCopySpacesForWindows` per window | `[3]` for 24 windows — the 15 on screen **plus 9 minimised or hidden ones that really are on this Space** — and `[]` for the other 97 |
| `SLSCopyManagedDisplaySpaces` | display → `Spaces: [3, 4]`, `Current Space: 3` |

The nine-window gap is the whole argument for the private layer: with public API alone, an
application whose only window on this Space is minimised is indistinguishable from an
application sitting on another Space.

## Design

### Two layers, one port

`SpaceMembershipSource` answers one question: *which of these windows are on the current
Space?* The answer is optional: `nil` means «this layer cannot answer», and the caller falls
back. Availability is therefore decided per answer, not once at start-up — a layer that
degrades later degrades observably.

- **Public layer (default, always answers).** The candidates whose `isOnScreen` flag is set
  in the snapshot S02 already took. No second call to the window server, so the two answers
  cannot disagree about a window that closed in between, and the layer is a pure function of
  the snapshot. Measured equal to `CGWindowListCopyWindowInfo(.optionOnScreenOnly)`: both
  gave the same fifteen layer-0 windows.
- **Private layer (opt-in).** `SLSMainConnectionID`, `SLSCopyManagedDisplaySpaces` for the
  active Space identifier, and `SLSCopySpacesForWindows` per window; a window is on the
  current Space when its Space list contains the active identifier. Resolved with `dlopen`
  and `dlsym` in exactly one file, `SkyLightShim.swift`, which is the only file the S01
  guard allowlists for dynamic loading. Missing symbol, connection zero, no display that
  names a current Space, or a per-window call that answers in an unknown shape — each of
  those makes the layer answer `nil` for that copy. Because the per-window symbol is
  exercised on every answer, a change in *its* behaviour is caught too, not only a change in
  the ones probed at start-up.

The user chooses the layer in preferences (S08). The default is public, because a private
API that disappears in macOS 16 must not take the application with it. Until S08 ships a
preferences window the choice is the user default `PrivateSpaceLayerEnabled` in the
application domain:

```nu
defaults write io.github.n0sfer666.humane-space-tab PrivateSpaceLayerEnabled -bool true
```

The preference is read on every answer, so switching it takes effect on the next copy —
no restart. If the private layer is asked for and answers `nil`, the app logs
`private space layer unavailable, falling back to the public one` and uses the public layer.

### Helper processes own windows

`kCGWindowOwnerPID` is not the application the user thinks of. Measured: Steam's visible
window is owned by *Steam Helper* (pid 1973), a process that is not a regular application
at all, while *Steam* itself owns no window. Attributing windows by owner alone would drop
Steam from the switcher entirely.

Resolution walks the process tree, but a parent link alone is not proof of ownership: an
application also becomes the parent of everything *launched* from it, and a menu-bar tool
started from a terminal would otherwise donate its windows to that terminal. The rule is
therefore containment, not descent: when a window's owner is not a regular application, the
first regular ancestor within four hops adopts the window **only if the owner's executable
lives inside that application's bundle**. Steam Helper at
`/Applications/Steam.app/Contents/MacOS/…` is inside Steam's bundle and is adopted; a tool
in `~/build` launched from Terminal is not, and its window is discarded.

Both facts come from public API: `proc_pidinfo(PROC_PIDT_SHORTBSDINFO)` gives the parent,
`proc_pidpath` gives the executable path, both from `<libproc.h>`, and the bundle path comes
from `NSRunningApplication.bundleURL`. No private API and no `dlsym` are involved. A window
whose chain proves nothing is discarded, exactly as in S02.

### The filter

An application survives the filter when **any** of these holds:

1. it has a window on the current Space; or
2. it has no windows at all — a freshly launched application has nowhere to be, and
   dropping it would make the switcher lose applications the stock one shows.

Everything else is filtered out: that is an application whose windows all live elsewhere.

Under the public layer, rule 1 sees only windows that are on screen, so two kinds of
application drop out of the list although the stock switcher keeps them:

- one whose current-Space windows are **all minimised**;
- one that is **hidden** (`Cmd+H`), because none of its windows are on screen either.

Both are the same limitation seen twice, and both are exactly what the private layer fixes:
SkyLight reports the Space of a minimised or hidden window just as it does for a visible
one. Keeping such applications unconditionally under the public layer would trade a missing
application for a foreign one — an application hidden on *another* Space would appear in the
list — so the public layer stays honest about what it can see instead of guessing.

### Where the code lives

Pure and tested in `SwitcherCore`: `WindowOwnership.resolve` (the walk plus the containment
proof, given parent and path lookups) and `CurrentSpaceFilter.apply`. `SystemPorts` gains
`ProcessHierarchy`, `SpaceMembershipSource` and `SpaceLayerPreference`. `SystemAdapters`
gains the libproc hierarchy, the on-screen source, the SkyLight shim and
`PreferredSpaceMembership`, which owns the choice between layers and the fallback — so the
composition root in `App` stays free of decisions and the fallback itself is unit-tested.

## Measured end to end

Both layers driven through the real adapters on a live machine with two Spaces. Two runs,
hours apart, on different sets of open applications:

| | First run | Second run |
|---|---|---|
| Windows read | 177 raw → 105 owned → 13 applications | 114 raw → 64 real → 46 owned → 6 applications |
| Public layer | 15 windows on the current Space → **12 applications** | 8 windows → **5 applications** |
| Private layer | 28 windows on the current Space → **12 applications** | 9 windows → **5 applications** |
| Dropped by the filter | Google Chrome, whose windows all live on the other Space | one application on the other Space |
| Helper resolution | Steam appears with its 14 windows, owned by *Steam Helper* | no helper-owned window was open |

Every window the ownership rule discarded in the second run was checked by hand: system XPC
services (`CursorUIViewService`, the AutoFill and Open/Save panel helpers) and menu-bar
applications (Raycast, Docker Desktop, Spotlight, `loginwindow`, WeatherMenu) — none of
which the stock switcher offers either.

The private layer consistently sees more windows than the public one — the minimised and
hidden windows of this Space. In both runs every one of them belonged to an application that
survives anyway, so the two layers agreed on the application list; the difference only shows
when an application's *only* window on this Space is minimised or hidden.

## Definition of Done

- [x] `WindowOwnership` and `CurrentSpaceFilter` are pure, with no system import.
- [x] The public layer needs no permission and no private symbol.
- [x] The private layer answers `nil` — never crashes and never silently empties the list —
      when a symbol is missing, the connection is zero, no display names a current Space, or
      a per-window answer has an unknown shape; the caller then falls back and logs it.
- [x] `dlopen`/`dlsym` appear in `SkyLightShim.swift` and nowhere else; the guard enforces it.
- [x] The private layer loads under Hardened Runtime with an ad-hoc signature and no
      entitlements: launched with the preference on, SkyLight is mapped into the process and
      no fallback event is logged.
- [ ] With the private layer on, an application whose only current-Space window is
      minimised stays in the list; with it off, the runbook shows it dropping out.
      *(Manual: needs a window minimised by hand, step 3 of the runbook.)*
- [x] Copying the inventory reports which layer produced the answer.
- [x] A window is adopted by an application only when its executable lives inside that
      application's bundle, so launching a tool from an application does not donate windows
      to it.

## Test cases

| # | Case | Expected |
|---|------|----------|
| # | Case | Expected |
|---|------|----------|
| 1 | Window owned by a regular application | attributed to it unchanged |
| 2 | Helper inside the application's bundle | attributed to the application |
| 3 | Helper chain inside the bundle, three hops | attributed to the application |
| 4 | Chain of exactly the hop limit | still resolves |
| 5 | Chain longer than the hop limit | window discarded |
| 6 | Process launched by an application it does not belong to | window discarded |
| 7 | Bundle path that is a prefix of a longer sibling path | window discarded |
| 8 | Regular application with no bundle path | adopts nothing |
| 9 | Helper with no executable path | window discarded |
| 10 | Chain that reaches no regular application | window discarded |
| 11 | Parent lookup returns the process itself, or a cycle | terminates, window discarded |
| 12 | No windows, or no regular applications | empty result, no crash |
| 13 | Application with a window in the current-Space set | kept |
| 14 | Application whose windows are all outside the set | dropped |
| 15 | Application with no windows | kept |
| 16 | Empty current-Space set | only windowless applications remain |
| 17 | Preferred layer answers | its answer and its name are used |
| 18 | Preferred layer answers `nil` | public layer answers, fallback is logged |
| 19 | Both layers answer `nil` | empty membership, still no crash |
| 20 | Display reports its current Space as a number, a dictionary, or nonsense | first two parsed, third refused |

## Manual runbook

1. On Space 1 open two applications; move one to Space 2 and return to Space 1.
2. Menu bar → **Copy Inventory**, paste: the application moved to Space 2 is absent, the
   one on Space 1 is present, and the header names the layer in use.
3. Minimise (or `Cmd+H`) the only window an application has on Space 1 and copy again. With
   the public layer it disappears from the list — expected. Set
   `PrivateSpaceLayerEnabled` to true and copy again *without restarting the app*: the
   header says `private (SkyLight)` and the application is back.
4. Open Steam (or any application whose window belongs to a helper process inside its
   bundle): it appears in the list under the application's name, not the helper's. Then run
   a menu-bar tool from a terminal: its windows must **not** be added to the terminal.
5. `/usr/bin/log show …` → no window identifiers, no application names, no Space
   identifiers in the log.

## Risks and open questions

- **Hidden applications drop out under the public layer**, like minimised-only ones; see
  «The filter». The private layer is the fix, and turning it on is one preference away.
- **The private layer is unsupported API.** It is opt-in, isolated in one file, resolved
  dynamically, and fails closed. `unsafeBitCast` on `dlsym` results is unavoidable there
  and is confined to that file.
- **`SLSCopySpacesForWindows` returned `[]` rather than the other Space's identifier** for
  windows elsewhere. The membership test is therefore "contains the active Space id", which
  is correct either way, but the empty result is not documented behaviour and could change.
- **The filter is application-level.** A surviving application still reports every window it
  owns, including those on other Spaces, so the counts in the summary are machine-wide. The
  switcher switches applications, so this changes nothing yet; window-level pruning is S05's
  problem if it ever needs a window list.
- **Sticky windows** (assigned to every Space) are reported on the current Space by both
  layers, which is the behaviour a user expects.
- **Open:** whether a window dragged between Spaces mid-cycle needs invalidation. The
  snapshot model of S02 makes each keypress independent, so probably not; revisited in S05.
