# S06 — Activation

**Status:** agreed · **Depends on:** S00, S05 · **ADRs:** —

## Goal

Make a committed session actually switch: raise the application the user chose,
unhide it if it was hidden, and report honestly when the process is gone. This is
the last piece that makes the switcher a switcher; showing the choice is S07.

## Non-goals

- Choosing *which* application — S05 owns the session and hands over one process.
- Restoring a minimised window — deliberately not done, see below.
- Raising a particular window of an application (`Cmd+~`) — S12+. Raising the window the
  user picked in the ribbon is S16, which revises the verdict on `kAXRaiseAction` below.
- Turning the tap to `.intercept` — still S07. Until then the system switcher
  activates first and ours activates the same application a moment later.

## Design

### One API, chosen for what it does not need

| Way to raise an application | Permission | Verdict |
|---|---|---|
| `NSRunningApplication.activate()` | none | **chosen** — unhides, works from a background accessory process |
| `activate(options: .activateIgnoringOtherApps)` | none | rejected: deprecated in macOS 14, and stealing activation is exactly what the cooperative API replaced |
| `AXUIElementPerformAction(kAXRaiseAction)` | Accessibility | rejected for the application case: it raises a window rather than an application. The grant argument expired when S07 took it for interception, and S16 uses this call for the window case |
| Private SkyLight ordering | none, but private | rejected — S00 keeps the private layer to the single S03 shim |

`activate()` needs no permission at all. That matters: until S07 turns the tap to
`.intercept` the app runs on Input Monitoring alone, and even afterwards the
Accessibility grant buys interception, not activation.

### Hidden, minimised, gone

Measured on the development machine, an accessory process activating another
application while a third one is frontmost:

| Case | `activate()` | Result |
|---|---|---|
| Ordinary background application | `true` in 8–18 ms | frontmost within 150 ms |
| Application hidden with `Cmd+H` | `true` in 42 ms (first call of the process) | unhidden **and** frontmost; no separate `unhide()` needed |
| Application whose only window is minimised | `true` in 16 ms | frontmost, window stays in the Dock |
| Process that has exited | no object to call | reported as a failure |

The minimised case is **parity, not a gap**: system `Cmd+Tab` also leaves the window
in the Dock and switches only the menu bar and focus. Restoring it is the job of the
Option-on-release gesture, which is S12+ and is the first thing here that would need
Accessibility.

A frozen snapshot (S05) can name a process that quit mid-gesture. There is no
fallback to the next candidate: silently switching to something the user did not
choose is worse than not switching. The effect says the activation failed, the log
records it without naming anything, and the session ends either way.

### Where activation happens

`SwitcherMachine` stays pure and still answers `committed(pid)`. The coordinator —
already the place that owns the snapshot and the MRU order — performs the activation
through an injected closure and downgrades the effect to `activationFailed(pid)` when
the process is gone. `SwitcherCore` keeps its no-system-imports rule; `App` passes
the adapter in.

| Effect | Meaning |
|---|---|
| `committed(pid)` | the session ended on this application **and** it was raised |
| `activationFailed(pid)` | the session ended on this application and it could not be raised |

Activation runs inside the event-tap callback, on the commit keystroke. At 8–42 ms it
is above one frame but two orders of magnitude below the ~1 s tap timeout (S01
§Concurrency), and nothing is being drawn at that moment. It is measured in the
runbook and re-measured if S07 adds work to the same keystroke.

## Definition of Done

- [x] An `ApplicationActivator` port in `SystemPorts`, its `NSRunningApplication` adapter, and no other way to raise an application anywhere in the sources.
- [x] Committing a session raises the selected application; cancelling, stepping and stray commands raise nothing.
- [x] A commit on a process that no longer exists yields `activationFailed` and leaves no session open.
- [x] The log distinguishes a raised commit from a failed one and still names no application (S00).
- [x] The whole suite is green; `swift-format --strict` and `swiftlint --strict` are clean.
- [x] On a real machine a full `Cmd+Tab` gesture leaves the chosen application frontmost, including when it was hidden — proven on the probe binary, which carries the Input Monitoring grant the freshly built bundle loses (S05 risk).
- [x] The Release bundle still declares zero entitlements and links no non-system library.

## Test cases

| # | Case | Expected |
|---|------|----------|
| 1 | commit on an open session | activator called once, with the selected pid |
| 2 | commit when the activator succeeds | `committed(pid)` |
| 3 | commit when the activator fails | `activationFailed(pid)`, session closed |
| 4 | cancel on an open session | activator never called |
| 5 | step within a session | activator never called |
| 6 | commit with no session open | `ignored`, activator never called |
| 7 | commit after two steps | the pid of the third application is the one activated |
| 8 | log events for both commit outcomes | two distinct payload-free events in the switcher category |
| 9 | adapter, pid that belongs to no process | activation fails without raising anything |
| 10 | adapter, live pid | handed to AppKit, whose answer it returns unchanged |

The adapter's happy path cannot be asserted in a unit test: the test runner is a
`.prohibited` process, so AppKit refuses activation for it whatever pid it is given.
That half is proven live — the measurement table above and the runbook below.

## Manual runbook

1. Build and launch the Release bundle, grant Input Monitoring, relaunch.
2. Hold Command, press Tab once, release → expected: the previous application is
   frontmost, and the log shows `switcher session committed`.
3. Hide an application with `Cmd+H`, then switch to it → expected: it is unhidden and
   frontmost; nothing else was unhidden.
4. Minimise every window of an application, then switch to it → expected: it becomes
   frontmost with no window restored — the same as the system switcher.
5. Quit an application while holding Command mid-gesture, then release on its tile →
   expected: `switcher activation failed` in the log, nothing else raised, no wedged
   session on the next gesture.

### Measured end to end

The full chain through a real event tap, gestures posted with `CGEvent.post`:

```
frontmost before: VLC
  hotkey activated the switcher moving forward → switcher session opened → selection 1: Telegram of 6
  hotkey stepped forward → switcher selection moved → selection 2: Ghostty
  hotkey cancelled the session → switcher session cancelled
  hotkey committed the session → switcher session committed → raised Telegram
frontmost after: Telegram
```

## Risks and open questions

- **Cooperative activation.** macOS 14 made activation something the frontmost
  application can refuse to yield. Measured working from a non-frontmost accessory
  process, but the guarantee is not documented; runbook step 2 is the regression test,
  and a refusal degrades to `activationFailed` rather than to a wrong switch.
- **Double activation until S07.** In `.observe` mode the system switcher raises its
  own choice first and ours raises the same application right after. Diverging choices
  would be visible as a flicker; that is a symptom worth watching in the runbook, and it
  disappears the moment the tap starts intercepting.
- **`activate()` is asynchronous.** It returns before the switch is complete; the
  frontmost application changed within 150 ms in every measurement. Nothing in S06
  waits for it, and S07 must not either.
