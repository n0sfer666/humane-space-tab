# S15 — The deaf tap

**Status:** agreed · **Depends on:** S04, S10 · **ADRs:** —

## Goal

An event tap can be alive, enabled, in intercept mode — and still never see a key press.
macOS silently strips `keyDown` and `keyUp` from the tap's mask when the process is denied
Input Monitoring, and leaves `flagsChanged` behind. Everything S10 looks at says the app is
working; the switcher is deaf. S15 makes the app notice, say so, and name the cure.

## What actually happens

Observed on macOS 15 with an ad-hoc signed build, Accessibility granted:

```
tap  pid=21356  opts=0 (active)  enabled=true  mask=0x1000
```

The app asked for `0x1c00` — `keyDown | keyUp | flagsChanged`. It got `0x1000`, modifier
changes only. `CGEvent.tapCreate` returned a port, `AXIsProcessTrusted()` was true, and
`tccd` recorded the tap's own permission check as allowed:

```
Evaluated composed authorization from kTCCServicePostEvent to parent kTCCServiceAccessibility: Allowed
```

The refusal is a *different* service — `kTCCServiceListenEvent`, the Input Monitoring list —
and it is never reported to the app. Removing the app's row there (`tccutil reset
ListenEvent <bundle-id>`) and relaunching restored `0x1c00` and the switcher started
working, without any grant being added. So Input Monitoring is not a permission this app
needs: an **absent** row is fine, and only a **denying** one breaks it.

A denying row is not exotic. Ad-hoc signing binds a TCC row to the bundle's cdhash, and
every rebuild produces a new one. A row left over from an older build shows as a switch that
is on while the access behind it is refused — the state this app shipped into on the first
machine it was installed on.

## Non-goals

- **Requesting Input Monitoring.** The app does not need it, and asking for a permission it
  can work without would contradict S00. It reads the outcome and never the permission.
- **Repairing TCC.** `tccutil` is the user's to run. The app explains; it does not reach into
  another process's privacy database.
- **Detecting *why* the tap is deaf.** Secure input, a denying row and a future reason the
  system invents all look the same from here. The app reports what it can prove — that key
  presses are not arriving — and names the one cure it knows.

## Design

### Ask the system what the tap actually got

`CGGetEventTapList` reports every tap in the session with its `eventsOfInterest` as the
window server rebuilt it. Filtering it to this process and looking for both key bits answers
the question directly, with no guessing from permissions:

```
deliversKeyEvents = taps(of: getpid()).contains { $0.eventsOfInterest ⊇ keyDown|keyUp }
```

This is a fact about the tap, not an inference from a permission. It stays true when the
next macOS release invents another reason to withhold key events, and it is the only signal
that survives a permission the app is never told about.

It is a port — `KeyEventDelivery` — for the same reason every other system fact is: the
state machine that consumes it must be testable without a window server.

### One more state, derived like the rest

S10's rule holds: state is computed, never stored. It now takes three facts instead of two.

| Trusted | Tap | Delivers keys | State | What the menu says |
|---|---|---|---|---|
| no | none | — | `blocked` | Accessibility is off; **Grant Accessibility…** |
| yes | none | — | `blocked` | macOS refused the tap; relaunching is the only cure |
| yes | intercept / observe | no | `deaf` | macOS is withholding key presses; **Open Input Monitoring…** |
| yes | observe | yes | `observing` | the switcher can see `Cmd+Tab` but not take it over |
| yes | intercept | yes | `intercepting` | nothing |

`deaf` outranks `observing`: a tap that receives nothing cannot observe either, so reporting
the milder problem would send the user to the wrong list.

### The cure is the message

The mask is decided when the tap is created, so nothing the running app does to a deaf tap
makes it hear. The user has to remove the app's row from Input Monitoring — the menu says
exactly that and opens the pane — and the tap has to be built again afterwards.

Rebuilding is already what `refresh()` does when the app is activated, so `deaf` joins the
conditions that make it rebuild. Fixing the row and clicking back into the app is then
enough; quitting is the answer only when the app is never activated.

### Where it is said

The menu bar, as S10 decided: the icon carries the warning, the first menu item carries the
sentence, and the action sits under it. **Open Input Monitoring…** is a second deep link
beside the Accessibility one, behind its own port — the accessibility authority answers for
one service and should not grow a second one's pane.

## Definition of Done

- [ ] A tap whose mask lost the key bits is reported as `deaf`, not as `intercepting`.
- [ ] The delivery check reads the live tap list, and reports only this process's taps.
- [ ] `deaf` shows the warning icon, its own sentence, and **Open Input Monitoring…**.
- [ ] Activating the app while `deaf` rebuilds the tap, so a fixed row needs no relaunch.
- [ ] S00, S10 and both READMEs stop claiming Accessibility is the only thing that gates the
      keyboard, and name the deaf-tap cure.
- [ ] The whole suite is green; `swift-format --strict` and `swiftlint --strict` are clean.
- [ ] The Release bundle still declares zero entitlements and links no non-system library.

## Test cases

| # | Case | Expected |
|---|------|----------|
| 1 | state, trusted + intercept + delivers | `intercepting` |
| 2 | state, trusted + intercept + deaf | `deaf` |
| 3 | state, trusted + observe + deaf | `deaf`, not `observing` |
| 4 | state, no tap + deaf | `blocked`, unchanged by delivery |
| 5 | state, `deaf` | needs attention, offers Input Monitoring, offers no grant |
| 6 | centre, tap goes deaf | observers hear `deaf` once |
| 7 | centre, activation while `deaf` | the tap is rebuilt |
| 8 | centre, activation while `intercepting` | the tap is left alone |
| 9 | menu, `deaf` | the pane item is present; the grant item is not |
| 10 | menu, `intercepting` | neither item, no explanation row |
| 11 | delivery, a mask with only `flagsChanged` | not delivering |
| 12 | delivery, a mask with both key bits | delivering |

## Manual runbook

1. With the switcher working, open **System Settings → Privacy & Security → Input
   Monitoring** and switch the app **off** → expected: within a moment of returning to the
   app the icon shows the warning and the menu offers **Open Input Monitoring…**.
2. Press `Cmd+Tab` → expected: the system switcher, because the tap is deaf.
3. Remove the app's row with **−**, quit and reopen → expected: the plain icon, and
   `Cmd+Tab` belongs to the app again.
4. `tccutil reset ListenEvent io.github.n0sfer666.humane-space-tab`, then relaunch →
   expected: the same recovery from the command line.

## Risks and open questions

- **The tap list is a snapshot.** It is read right after the tap is created; if the window
  server ever publishes the tap asynchronously, a first read could miss it and report a false
  `deaf`. The state is recomputed on every activation and every rebuild, so a false reading
  corrects itself rather than sticking.
- **Another process could hold a tap in our name.** It cannot: the list is filtered on this
  process's own pid, and nothing else runs in it.
- **The cure names one cause.** Secure input produces the same symptom through a different
  mechanism, and this message would then point at the wrong list. It no longer has to:
  [S20](S20-secure-input.md) reads the session flag directly, and the state it publishes ranks
  below `deaf` precisely so that a tap missing the key bits keeps naming its own cure.
