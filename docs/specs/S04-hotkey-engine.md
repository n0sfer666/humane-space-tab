# S04 — Hotkey engine

**Status:** agreed · **Depends on:** [S00](S00-threat-model.md), [S01](S01-architecture.md) ·
**ADRs:** [0001](../adr/0001-foundation.md)

## Goal

Turn raw keyboard events into a five-word command vocabulary — activate, step, cancel,
commit — and own the lifecycle of the event tap that produces them: creation, failure
when Accessibility is absent, and re-arming after the system disables it.

This is the module S00 names as "exactly one module receives raw `CGEvent`s". Everything
downstream of it works on commands and never sees a key code.

## Non-goals

- Which application is selected, and in what order — [S05](README.md).
- Raising the selected application — S06. Drawing anything — S07.
- Persisting a custom shortcut and editing it in the UI — S08. S04 accepts a `Shortcut`
  value and stores nothing.
- Explaining a missing Accessibility grant to the user — S10. S04 reports the fact and
  keeps the app alive.
- Acting on other keys during a session (`Q` to quit the selected app, `H` to hide) —
  S12. S04 consumes those keys and maps them to nothing.

## Design

### Why an event tap

`Cmd+Tab` is owned by the system. The mechanism has to be able to see the shortcut, to
see the modifier being *released* (the whole gesture is "hold Command, tap Tab"), and
eventually to swallow the event so the system switcher does not also run.

| Mechanism | Sees Cmd+Tab | Sees modifier release | Can swallow | Verdict |
|---|---|---|---|---|
| `NSEvent.addGlobalMonitorForEvents` | yes | yes | **no** | rejected: both switchers would run |
| `NSEvent.addLocalMonitorForEvents` | own app only | — | yes | rejected: wrong scope |
| Carbon `RegisterEventHotKey` | **no**, reserved by the system | **no**, key-down only | yes | rejected |
| `CGEventTap` | yes | yes | yes | chosen |

`CGEventTap` is also the reason the app needs Accessibility at all, which is why S00
exists before this spec.

### Two layers

The interpretation is pure and lives in `SwitcherCore`; only the tap adapter in
`SystemAdapters` ever touches `CGEvent`.

```
CGEvent ──▶ CGEventTapHotkeySource ──▶ KeyStroke ──▶ HotkeyInterpreter ──▶ HotkeyDecision
             (SystemAdapters)          (value)       (SwitcherCore, pure)
```

`KeyStroke` carries a key code, a modifier set and a phase (`down`, `up`,
`flagsChanged`). It is a value passed down the stack and released with the call; nothing
retains it, nothing logs it, nothing writes it anywhere. `SwitcherCore` imports no system
framework, so the interpreter is impossible to test against a live keyboard by accident —
the S01 guard enforces that.

### The vocabulary

```swift
enum SelectionDirection { case forward, backward }
enum HotkeyCommand { case activate(SelectionDirection), step(SelectionDirection), cancel, commit }
enum HotkeyDecision { case passThrough, consume, command(HotkeyCommand) }
```

`consume` is "this event belongs to the switcher but means nothing" — the key-up of Tab,
a letter typed mid-gesture. `command` implies consumption. `passThrough` returns the
event to the system byte-for-byte unmodified.

### Interpretation

The interpreter is a function of the stroke, the configured shortcut, and one boolean the
caller supplies: whether a switcher session is currently open. It holds no state of its
own — the session state belongs to S05, and duplicating it here would create two sources
of truth.

| Session | Event | Decision |
|---|---|---|
| idle | shortcut key down, modifiers **exactly** the shortcut's | `command(.activate(.forward))` |
| idle | same plus Shift | `command(.activate(.backward))` |
| idle | shortcut key down with any other extra modifier | `passThrough` |
| idle | anything else | `passThrough` |
| open | shortcut key down (± Shift) | `command(.step(.forward))` / `.step(.backward)` |
| open | `Cmd+Option+Esc` | `passThrough` — Force Quit belongs to the system |
| open | Escape down | `command(.cancel)` |
| open | `flagsChanged`, shortcut modifiers no longer held | `command(.commit)` |
| open | any other key down or up | `consume` |

Consuming *everything* while a session is open is deliberate: it is what the system
switcher does, and passing stray keystrokes to whichever application happens to be
frontmost during the gesture would be both surprising and a way to type into the wrong
window.

Modifier equality is exact. `Ctrl+Cmd+Tab` is somebody else's shortcut, not a sloppy
version of ours, so it passes through untouched.

One combination is carved out of "consume everything": `Cmd+Option+Esc`. An intercepting
tap sits in front of the whole session, so swallowing Force Quit would take away the one
escape hatch a user has when this app misbehaves. It passes through in every phase.

Shift is how the gesture reverses, which costs something: a shortcut that already contains
Shift — `Cmd+Shift+Tab` as the *activation* — has no backward direction, because the
reversed form would be indistinguishable from the plain one. Such a shortcut moves forward
only. This is a limitation of the design, not an oversight, and S08 should refuse to record
one rather than let it look broken.

Until S05 exists there is no session state to consult, so the app wires `sessionOpen` to a
constant `false`. The consequence is deliberate and visible in the runbook: a development
build can log `activate` and nothing else, because every other command needs an open
session.

### Tap lifecycle

The tap is created at `.cgSessionEventTap`, head-inserted, listening to `keyDown`,
`keyUp` and `flagsChanged`, and attached to the main run loop.

Interception is a parameter, not a constant:

- **`.observe`** — a listen-only tap. Decisions are computed and logged; every event
  reaches the system regardless. This is what the app wires in S04, so that installing a
  development build cannot leave the machine without a working `Cmd+Tab` while the
  switcher itself does not exist yet.
- **`.intercept`** — a default (active) tap that actually swallows. Switched on in S05,
  when there is a switcher to show instead.

Ownership of the Mach port and the run loop source is a separate object whose whole job is
that pair: it attaches on creation and detaches in `deinit`. The tap holds an unretained
pointer back to the engine, so an engine released without a `stop()` would otherwise leave
a live tap calling into freed memory — inside a process that holds Accessibility. Releasing
the engine now releases the handle, which removes the source and invalidates the port.

macOS disables a tap that takes too long in its callback (`tapDisabledByTimeout`) and on
certain user input (`tapDisabledByUserInput`). Both arrive as events; the adapter
re-enables the tap in place and records `hotkeyTapReenabled`. A tap that is never
re-armed is the classic failure mode of this kind of app — it stops working silently,
minutes after launch.

When `CGEvent.tapCreate` returns `nil` — which is what an ungranted permission looks like
for an intercepting tap — `start()` returns `.unavailable`, the event is logged, and the
app keeps running with a menu bar item. Nothing is prompted from here: S10 owns asking the
user for the grant and explaining it.

A listen-only tap is weaker evidence. Measurement on macOS 15 (below) shows that an
ad-hoc signed bundle with no grant at all still gets a valid tap in `.observe` mode, so
`start() == .running` proves the tap exists, not that events flow. The permission that
governs listening is Input Monitoring, and the one that governs swallowing is
Accessibility; only the latter makes `tapCreate` fail outright. This is why the runbook
checks the log after a real keypress rather than trusting `start()`.

### What the log may contain

`hotkeyTapStarted`, `hotkeyTapStopped`, `hotkeyTapUnavailable`, `hotkeyTapReenabled` and
one event per command class. `LogEvent` remains a payload-free enum, so a key code cannot
reach the log even by mistake: there is no parameter to put it in.

### Measured end to end

Run on macOS 15 against the real window server, through a probe package that drives the
adapter with posted key events (`Ctrl+F19`, chosen because it does nothing on this
machine) and a second, tail-appended listen-only tap acting as a witness.

| Question | Result |
|---|---|
| Does the tap deliver events to the interpreter? | yes — one gesture produced `activate`, `step` forward, `step` backward, `cancel`, `activate`, `commit`, in that order |
| Does `.intercept` remove the event from the system? | yes — the witness tap saw key code 81 (unrelated) and never saw 80 (the shortcut) |
| Does `.observe` leave events alone? | yes — the same witness saw every event |
| Does the shipped bundle reach the same path? | yes — the Release build logs `hotkey activated the switcher moving forward` for a posted `Cmd+Tab` |
| With a session open, does `Cmd+Option+Esc` survive? | yes — the witness saw key code 53 while the shortcut and an unrelated key were both swallowed |
| Does releasing the engine without `stop()` detach the tap? | yes — after the reference was dropped the witness saw the shortcut again, and nothing crashed |

The swallow question is the one that matters most and the one a unit test cannot answer:
the witness tap is the only way to see that the event is gone rather than merely ignored.

## Definition of Done

- [ ] `HotkeyInterpreter` lives in `SwitcherCore` and compiles with no system import.
- [ ] `Cmd+Tab` while idle yields `activate(.forward)`; with Shift, `activate(.backward)`.
- [ ] Any extra modifier on the shortcut yields `passThrough`.
- [ ] While a session is open, every key event is consumed and only the mapped ones
      produce a command.
- [ ] Releasing the shortcut's modifiers yields exactly one `commit`.
- [ ] Escape yields `cancel`.
- [ ] A non-default shortcut is honoured without code changes.
- [ ] `tapDisabledByTimeout` and `tapDisabledByUserInput` re-enable the tap and log it.
- [ ] Without Accessibility, `start()` reports `unavailable`, logs it, and the app stays up.
- [ ] `Cmd+Option+Esc` reaches the system with a session open, in `.intercept` mode.
- [ ] Releasing the engine detaches the tap even if `stop()` was never called.
- [ ] An intercepting tap removes the shortcut from the event stream, measured with a
      downstream witness tap, and leaves unrelated keys untouched.
- [ ] Runbook: in `.observe` mode on a real machine, one gesture produces one command line
      in the log, the system switcher still works, and no key code appears anywhere in the log.

## Test cases

| # | Case | Expected |
|---|---|---|
| 1 | idle, Cmd+Tab down | `command(.activate(.forward))` |
| 2 | idle, Cmd+Shift+Tab down | `command(.activate(.backward))` |
| 3 | idle, Ctrl+Cmd+Tab down | `passThrough` |
| 4 | idle, Cmd+Option+Tab down | `passThrough` |
| 5 | idle, Tab down without Command | `passThrough` |
| 6 | idle, Cmd+Tab **up** | `passThrough` |
| 7 | idle, letter down | `passThrough` |
| 8 | idle, `flagsChanged` releasing Command | `passThrough` |
| 9 | open, Cmd+Tab down | `command(.step(.forward))` |
| 10 | open, Cmd+Shift+Tab down | `command(.step(.backward))` |
| 11 | open, Escape down | `command(.cancel)` |
| 12 | open, `flagsChanged` without Command | `command(.commit)` |
| 13 | open, `flagsChanged` still holding Command | `consume` |
| 14 | open, Tab up | `consume` |
| 15 | open, letter down | `consume` |
| 16 | custom shortcut Option+Grave, idle, matching down | `command(.activate(.forward))` |
| 17 | custom shortcut, idle, old Cmd+Tab down | `passThrough` |
| 18 | multi-modifier shortcut Ctrl+Option+Tab, exact match | `command(.activate(.forward))` |
| 19 | modifier set comparison ignores capsLock and numeric pad | matches |
| 20 | `HotkeyTapMode.observe` for any decision | never swallows |
| 21 | `HotkeyTapMode.intercept` for `consume` and `command` | swallows; `passThrough` does not |
| 22 | A shortcut with no modifiers, session open, `flagsChanged` | `consume` — the hold gesture does not apply |
| 23 | `CGEventFlags` carrying caps lock, Fn and the numeric pad | mapped to modifiers without them |
| 24 | `CGEventType` that is not a key event | no `KeyStroke` |
| 25 | Every `HotkeyCommand` mapped to a log event | distinct events, all in the `hotkey` category |
| 26 | `Cmd+Option+Esc` down and up while a session is open | `passThrough`; `Option+Esc` still cancels |
| 27 | A shortcut containing Shift | activates forward; the same keys without Shift pass through |
| 28 | `start()` twice | one tap, one `hotkeyTapStarted` |
| 29 | `stop()` without `start()` | nothing logged |
| 30 | `stop()` twice, then `start()` again | one `hotkeyTapStopped`, then a second `hotkeyTapStarted` |
| 31 | Tap event of a disabling type | recognised as `disabled` rather than as a stroke |

## Manual runbook

Run from the repository root; `APP` is
`.build/xcode/Build/Products/Release/Humane Space Tab.app`.

1. `xcodegen generate && xcodebuild -project HumaneSpaceTab.xcodeproj -scheme HumaneSpaceTab
   -configuration Release -derivedDataPath .build/xcode build` → `** BUILD SUCCEEDED **`.
2. `open "$APP"` before granting Accessibility → the menu bar item appears, the app does
   not crash, and the log holds `hotkey tap unavailable`.
3. System Settings → Privacy & Security → Accessibility → add and enable the app, then
   quit and relaunch it → the log holds `hotkey tap started`. Note that step 2 may also
   log it: a listen-only tap is created without the grant, it simply stays silent.
4. Press `Cmd+Tab` once and release → the **system** switcher still appears (observe
   mode), and the log holds `activate`. This is the step that proves events actually
   reach the tap; if it logs nothing, the grant is missing, whatever step 3 showed.
5. Press `Cmd+Shift+Tab` → the log holds `activate` with the backward direction.
6. `/usr/bin/log show --last 5m --info --debug --predicate 'subsystem ==
   "io.github.n0sfer666.humane-space-tab"' --style compact` → no key codes, no key names,
   no application names anywhere in the output.
7. Leave the app running for ten minutes under load (a build in the background), then
   repeat step 4 → still one command per gesture; if the log holds `hotkey tap re-enabled`,
   the re-arm path worked rather than the tap dying.
8. Menu bar → Quit → `hotkey tap stopped` is logged and `pgrep -f HumaneSpaceTab` is empty.

## Risks and open questions

- **Ad-hoc signing invalidates the Accessibility grant on every rebuild**, so steps 3–5
  have to be repeated after each build during development. Known from S00; S10 makes it
  visible to users instead of mysterious.
- **`start() == .running` is not proof that events arrive.** A listen-only tap is created
  even without a grant; whether key events then flow depends on Input Monitoring, which
  the app cannot query without prompting. Until S05 switches to `.intercept`, a silent tap
  and a working tap look identical from inside the process. Runbook step 4 is the only
  check that separates them.
- **Auto-repeat.** Holding Tab down produces repeated key-down events. They are ordinary
  `step` commands, which is the native behaviour; S05 decides whether to rate-limit.
- **A slow callback kills the tap.** The interpreter is a pure function over a small
  value, and nothing in the callback touches the window server, so the budget is not at
  risk today. It becomes a real constraint in S06/S07, where activation and drawing must
  stay off the tap's thread.
