# S20 — Secure input

**Status:** agreed · **Depends on:** [S10](S10-permission-ux.md), [S15](S15-deaf-tap.md) · **ADRs:** —

## Goal

While macOS holds *secure input*, the window server delivers no key events to any session
tap. The switcher is alive, its tap is enabled in intercept mode with both key bits in its
mask, and `Cmd+Tab` still belongs to the system: nothing the app can see from S10 or S15 is
wrong, so it shows the working icon while doing nothing. S20 makes the app read the one fact
that explains it, name the process holding the input, and say what ends it.

## What actually happens

Secure input is what a password field turns on, so that no tap — this one included — can
read what is typed. It is a session-wide flag, and the session dictionary names its holder:

```
CGSessionCopyCurrentDictionary()["kCGSSessionSecureInputPID"] = 609
```

Observed on this machine after the ribbon stopped appearing: pid 609 was `loginwindow`,
holding the flag with no password field on screen and no lock in sight. The app had logged
`hotkey tap started` and `the switcher is intercepting the shortcut`, and not one
`hotkey activated` since launch. When the key later left the dictionary by itself, the same
process — never restarted — began logging activations again.

The hold is normal and constant in small doses: every password field takes it for as long as
it has focus. What is not normal is a hold that outlives the field, which is what a process
that crashes or forgets to balance `EnableSecureEventInput()` leaves behind. macOS attributes
the hold to the frontmost application at the time, not to whoever called it, so the name is a
lead rather than a verdict.

## Non-goals

- **Ending the hold.** `DisableSecureEventInput()` only balances a call this process made;
  the app cannot release another process's hold, and would not if it could.
- **Naming the culprit.** The session names the process the hold is attributed to. The app
  reports that name and says so; it does not guess which application really called.
- **Working around it.** There is no tap, no API and no mode that receives key events while
  secure input is held. The feature is an explanation, not a repair.
- **Watching what the holder does.** One PID, one name, no path stored, nothing logged.

## Design

### The fact, and the process behind it

`CGSessionCopyCurrentDictionary()` answers with a session dictionary; the key is present
exactly while some process holds secure input, and absent otherwise. The PID it carries is
named twice over — `NSRunningApplication` for anything with a bundle, `proc_pidpath` for
anything else — and stays unnamed rather than shown as a bare number when neither answers.

`SecureInputMonitor` is a port for the same reason every other system fact is one: the state
machine that consumes it is tested without a window server.

### Three seconds, and why the state machine is pure

A password field held for as long as a password takes is not a fault and must not turn the
menu bar into a warning. A hold reported only after **3 seconds** of the *same* holder skips
every ordinary one; a different PID starts the count again, so two password fields in a row
are two ordinary holds rather than one long one. Release is immediate — there is nothing to
debounce about a fault that ended.

`SecureInputWatch` in `SwitcherCore` owns that threshold against a clock passed in, so the
whole behaviour is tested on controlled time instead of by sleeping.

### One more state, ranked

S15's table gains a row. `secured` outranks `observing` and both working states, and yields
to `blocked` and `deaf`:

| Trusted | Tap | Delivers keys | Secure input | State |
|---|---|---|---|---|
| yes | intercept | yes | held > 3 s | `secured` |
| yes | intercept | yes | none | `intercepting` |
| yes | observe | yes | none | `observing` |

A tap that is handed no key presses is not intercepting anything, whatever its mask says —
and the mask is exactly why `deaf` still wins: a tap missing the key bits stays broken after
the hold ends, so the message that survives the hold is the one worth showing.

### The timer stops being conditional

S10 polls every two seconds while the permission is missing, and stops once it is there.
Secure input starts and ends without telling anyone, so the poll now runs for as long as the
app does. It rebuilds nothing while there is a tap — a deaf tap rebuilt every two seconds
would cost the user open sessions for nothing — so the tick only looks and reports; while the
state is `blocked` it refreshes exactly as before.

### The message names the holder

The menu bar, as S10 decided: the warning icon, and a first menu item naming the process and
the cure — locking the screen and unlocking it clears the flag on every machine this has been
seen on. A hold whose process cannot be named gets the same sentence without the name. Both
sentences are in all fifteen languages of S19, and there is no menu action: nothing the app
can do about it is more honest than a sentence.

## Definition of Done

- [ ] A hold longer than three seconds shows the warning icon and a menu line naming the holder.
- [ ] Typing a password changes neither icon nor menu.
- [ ] The end of a hold restores the previous state by itself, without a relaunch and without
      rebuilding the tap.
- [ ] A holder that cannot be named still produces the warning, in its own words.
- [ ] The state is derived, never stored, and ranks below `blocked` and `deaf`.
- [ ] Both sentences exist in all fifteen languages, and the guides say what to do.
- [ ] Reading another process's name is allowlisted in the source guard and stated in S00.
- [ ] The whole suite is green; `swift-format --strict` and `swiftlint --strict` are clean.

## Test cases

| # | Case | Expected |
|---|------|----------|
| 1 | watch, one holder for 2.9 s | nothing reported |
| 2 | watch, one holder for 3 s | reported |
| 3 | watch, a reported holder released | forgotten at once |
| 4 | watch, a second holder at 2.9 s | its own count, not the age of the first |
| 5 | watch, a holder reported and still there at 30 s | still reported |
| 6 | watch, a holder with no name | reported, unnamed |
| 7 | state, trusted + intercept + delivers + held | `secured` |
| 8 | state, trusted + observe + delivers + held | `secured`, not `observing` |
| 9 | state, no tap + held | `blocked`, unchanged by the hold |
| 10 | centre, a hold shorter than the threshold | nothing published |
| 11 | centre, a hold past the threshold | `secured(by:)` published once |
| 12 | centre, the hold ends | the previous state returns, the tap is neither stopped nor rebuilt |
| 13 | centre, a hold present at launch | timed from launch, not from the first tick |
| 14 | centre, the permission in place | the timer keeps arming itself |
| 15 | menu, `secured` | the holder is named; neither the grant nor the pane is offered |

## Manual runbook

1. Click into a password field — the login window, `sudo` in a terminal, a keychain prompt —
   and hold it for a second or two → expected: the menu bar icon does not change.
2. Keep a password field focused for more than three seconds → expected: the icon becomes the
   warning, and the menu's first line names the application holding the keys.
3. Leave the field → expected: within about two seconds the icon is plain again, and
   `Cmd+Tab` opens the ribbon without a relaunch.
4. Force a stuck hold — in a terminal, `swift -e "import Carbon; EnableSecureEventInput();
   sleep(20)"` → expected: the warning appears after three seconds, names the terminal
   application, and clears by itself when the process exits.
5. While the warning is up, press `Cmd+Tab` → expected: the system switcher, because no key
   press reaches the tap.
6. Lock the screen and unlock it → expected: a hold that outlived its field is gone, which is
   what the message tells the user to do.

## Risks and open questions

- **The name is attribution, not proof.** macOS credits the frontmost application, so a hold
  left behind by something else is reported under an innocent name. The sentence says the
  name is who is *holding* the keys, and the cure it names does not depend on the name being
  right.
- **`proc_pidpath` reads another process.** It answers with a path and nothing else, only for
  the one PID the session named, and only to turn a number into a word. It is allowlisted in
  the source guard for two files, and S00 records why.
- **Three seconds is a judgement.** Long enough that no password field reaches it, short
  enough that a stuck hold is explained before the user starts looking for the bug in this
  app. It is a constant in one place if the machine ever disagrees.
