# S05 — Switcher state machine

**Status:** agreed · **Depends on:** S02, S03, S04 · **ADRs:** —

## Goal

Turn the command stream of S04 into a switching session: which applications are
offered, in which order, which one is selected at every moment, and what happens
when the user releases Command or presses Escape. This is the part that decides
*what* would be switched to; raising it is S06 and showing it is S07.

## Non-goals

- Raising the chosen application — S06.
- Any window on screen — S07. Until then a session is observable only in the log.
- Per-window switching (`Cmd+~`, App Exposé) — S12+.
- Turning the tap to `.intercept` — deliberately deferred to S07: swallowing
  `Cmd+Tab` before anything is drawn and before anything is raised would leave the
  user with a dead shortcut. S05 runs alongside the system switcher and only records
  what it would have done.

## Design

### Order: seed from z-order, maintain from activations

macOS orders `Cmd+Tab` by most recent use, and that history predates our process.

| Source | Gives MRU | Cost | Verdict |
|---|---|---|---|
| `NSWorkspace.runningApplications` order | no — roughly launch order | free | rejected as an order |
| `AXObserver` on focus changes | yes | one observer per app, Accessibility per app | rejected: heavy. S16 later reads window titles over `AX`, but never keeps an observer alive |
| Private `CGSGetWindowOrder` | yes | private, already have a public equivalent | rejected |
| On-screen window list, front to back | yes, for anything with a window | one window-server call, at launch only | **chosen as the seed** |
| `NSWorkspace.didActivateApplicationNotification` | yes, exactly | one notification | **chosen as the live signal** |

`CGWindowListCopyWindowInfo(.optionOnScreenOnly, …)` returns windows front to back;
the first appearance of each owner is the application order on screen. That seeds
`MRUOrder` at launch. From then on every activation notification moves one process
to the front. The seed and the signal share one type, so there is no second ordering
rule to keep in sync.

The option matters. The inventory of S02 asks for `.optionAll`, because minimised and
hidden windows must be counted, and **that list is not z-ordered**: measured side by side,
`.optionAll` returned `System Settings > Finder > Ghostty > Arc > Telegram > VLC` while
`.optionOnScreenOnly` returned `VLC > …` with VLC actually in front. So the window port
answers two questions — every real window, and the visible ones front to back — and only
the second seeds the order. They are two separate calls on the inventory source as well:
`inventory()` answers the snapshot, `frontToBackApplications()` answers the seed. Nothing
asks for both at once, so the seed's window-server call never runs inside the tap callback. The seed is run through the same ownership resolution as the
inventory (S03), otherwise an application whose windows belong to a helper process would
never match its own seed entry.

Applications the seed cannot see — minimised or hidden with no on-screen window, and
never activated since launch — are unknown to the order. They are appended after the
known ones in the inventory's own (alphabetical) order, and they take their real place
the first time they are used. This is a cold-start difference from the system switcher
that heals itself; it is not worth a private API.

### The session is a snapshot

Opening a session freezes the list. An application launching, quitting or changing
Space mid-gesture does not renumber what is under the user's fingers, which is what
the system switcher does and the only behaviour that keeps `Cmd+Tab+Tab` predictable.
A frozen entry may of course be gone by commit time; S06 owns that check.

The snapshot is the S02/S03 pipeline — running applications, window ownership, current
Space filter — ordered by `MRUOrder`. It is built inside the event-tap callback, which runs
on the main run loop (S01 §Concurrency, amended by this spec): the callback may do bounded
main-actor work, and this is that work. Its cost is on the critical path of the first `Tab`;
the budget is one frame (16 ms), two orders of magnitude below the ~1 s that disables a tap.
Measured at 2.7 ms median, 7.2 ms worst. The first call of the process costs an order of
magnitude more — the SkyLight shim and the process caches are cold — so the launch-time seed
pays it before any user gesture.

### Selection

The front application is index 0 and is never the initial selection: `Cmd+Tab` means
"the one before this one". Opening forward selects index 1, opening backward selects the
last index; both wrap. With a single application the selection stays on it, matching the
system switcher, which still offers the front app as a target. Such a step reports
`ignored`: nothing moved, and S07 must not redraw.

### Effects

`SwitcherMachine` answers every command with what the outside world must do:

| Effect | Meaning |
|---|---|
| `ignored` | the command does not apply in this state |
| `opened` | a session now exists; read `session` for its contents |
| `moved` | the selection changed within the open session |
| `ignored` (on `step`) | the selection could not change — a session of one |
| `cancelled` | the session ended with nothing chosen |
| `committed(ProcessIdentifier)` | the session ended on this application |

The session itself is read from the machine rather than carried in the effect: one
source of truth for the overlay in S07, and no copy of the snapshot per keystroke.

Stray commands are ignored rather than trusted: `step`/`cancel`/`commit` with no session
open, and `activate` while one already is. The interpreter of S04 should never produce
them, but the machine is the place where that invariant is enforced and tested.

An `activate` over an empty list opens nothing and reports `ignored` — with no
application to offer there is no session to show.

### Measured end to end

Numbers from the live probe on the development machine; re-measured whenever the
pipeline changes.

| Question | Result |
|---|---|
| Snapshot cost inside the callback | 2.7 ms median, 7.2 ms worst of ten warm calls; 31.7 ms on the very first call, which the launch-time seed absorbs |
| Seed cost, launch only | 0.9 ms for six applications; never paid again |
| Does the seed match what is in front? | yes — after the fix below the first application in the order was the frontmost one |
| Does an activation move the application to the front? | yes — recording the last application in the order put it at index 0 of the next session |
| Does a `Cmd+Tab` gesture reach the machine through the tap? | yes — `activate` → `opened` (selection 1), `step` → `moved` (selection 2), `cancel` → `cancelled`, and a second gesture `commit` → `committed` |
| Does the Release bundle see the same events? | not observed: a freshly built ad-hoc bundle has no Input Monitoring grant, so its tap is silent until the grant is given again (see the risks) |

## Definition of Done

- [x] `SwitcherSession`, `SwitcherMachine` and `MRUOrder` are pure `SwitcherCore` types with no system imports, covered by the test cases below.
- [x] The order after seeding equals the front-to-back application order, and an activation moves that application to index 0.
- [x] A snapshot excludes our own process and everything filtered out by S02/S03.
- [x] Every stray command is ignored without changing state.
- [x] The whole suite is green; `swift-format --strict` and `swiftlint --strict` are clean.
- [x] On a real machine a held `Cmd+Tab` gesture logs an opened session, one step per `Tab`, and a commit. The application behind that commit is named only by the scratchpad probe: the shipped log stays payload-free (S00).
- [x] Building a snapshot inside the callback stays under one frame (2.7 ms median, 7.2 ms worst).
- [x] The Release bundle still declares zero entitlements and links no non-system library.

## Test cases

| # | Case | Expected |
|---|------|----------|
| 1 | session of three, opened forward | selection 1 |
| 2 | session of three, opened backward | selection 2 |
| 3 | step forward from the last index | wraps to 0 |
| 4 | step backward from 0 | wraps to the last index |
| 5 | single application, opened forward | selection 0 |
| 6 | single application, stepped | `ignored`, selection 0 |
| 7 | `activate` over an empty list | `ignored`, no session |
| 8 | `activate` while a session is open | `ignored`, session untouched |
| 9 | `step` with no session | `ignored` |
| 10 | `cancel` with no session | `ignored` |
| 11 | `commit` with no session | `ignored` |
| 12 | `cancel` on an open session | `cancelled`, no session left |
| 13 | `commit` on an open session | `committed(pid of the selection)`, no session left |
| 14 | commit after two forward steps | commits the third application |
| 15 | reopening after a commit | starts from the new snapshot |
| 16 | empty order, three applications | unchanged order |
| 17 | order seeded with the pids of the applications | applications follow the seed |
| 18 | order knows only some pids | known ones first, the rest in their incoming order |
| 19 | recording an activation | that application moves to index 0 |
| 20 | recording an activation twice | no duplicate entry |
| 21 | recording an unknown pid | it is prepended |
| 22 | seeding from a front-to-back window list | first appearance of each owner, in order |
| 23 | seeding ignores repeated owners and non-real windows | one entry per application |
| 23a | the order is full and one more activation arrives | the least recent process is forgotten |
| 23b | the inventory source excludes our own process | our pid is absent from the snapshot |
| 23c | the tap is re-armed while a session is open | a `cancel` command is emitted |
| 24 | coordinator opens with the snapshot ordered by MRU | first item is the front application |
| 25 | coordinator reports `isSessionOpen` across a full gesture | false, true while open, false after commit |
| 26 | log events cover every effect | distinct events, all in the switcher category |

## Manual runbook

1. `xcodegen generate && xcodebuild … -configuration Release build` → expected: build succeeds.
2. Launch the Release bundle → expected: `hotkey tap started` in the log. Then grant it
   Input Monitoring in System Settings and relaunch: without that grant the tap is created
   but sees nothing, and every step below stays silent.
3. Hold Command and press Tab once, release → expected: `switcher session opened` then `switcher session committed` in the log. Which application that was is not in the log by design; the probe prints it.
4. Hold Command, press Tab three times, release → expected: two `selection moved` lines between open and commit.
5. Hold Command, press Tab, press Escape, release → expected: `switcher session cancelled` and no commit line.
6. Minimise an application, repeat step 3 → expected: the minimised application still appears in the snapshot count, and the selection order is unaffected by minimising.
7. Switch to another Space and run the probe there → expected: the snapshot it prints holds the applications of that Space, not all of them.

## Risks and open questions

- **Cold-start order.** Applications with no on-screen window and no activation since
  launch sit at the end of the list. Accepted, documented above; measurable in runbook
  step 6.
- **Snapshot inside the callback.** The event tap has a system timeout; a slow snapshot
  would get the tap disabled. Measured at 2.7 ms median / 7.2 ms worst, and the tap already
  re-arms itself (S04), but if S12 widens the inventory this number must be re-measured.
- **A wedged session.** A `flagsChanged` release can be lost — the tap is disabled mid-hold,
  or another application steals the modifier — leaving the session open forever, which in the
  `.intercept` mode of S07 would mean a dead keyboard. Re-arming the tap therefore cancels an
  open session. This covers the disable path; the other paths are S07's problem, when a
  visible overlay makes a wedged session obvious.
- **The grant follows the binary.** An ad-hoc signed bundle loses its Input Monitoring
  grant on every rebuild, so a freshly built app is deaf until the user grants it again.
  That is why the live evidence above comes from a probe binary rather than the bundle.
  A stable signing identity (S11) and a permission flow that notices the deaf state (S10)
  are the fix; until then the runbook says to re-grant after each build.
- **Activation notifications need no permission**, but they stop arriving if our process
  is suspended. As an accessory application with a tap we are not suspended; if that ever
  changes, the seed can be rebuilt on session open.
- **The system switcher still runs** in `.observe` mode, so its activation lands in our
  MRU as well. That is correct: it is a real use of an application.
