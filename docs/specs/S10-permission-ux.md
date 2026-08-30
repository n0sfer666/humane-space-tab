# S10 — Permission UX

**Status:** agreed · **Depends on:** S04, S07 · **ADRs:** —

## Goal

Intercepting `Cmd+Tab` needs Accessibility. Without it the app is a menu bar icon that does
nothing, and macOS says so nowhere. S10 makes the app ask for the permission once, say
plainly what is broken while it is missing, start working the moment it is granted — without
a relaunch — and stop claiming to work when the grant is taken away.

## Non-goals

- Any second permission. S00 stands: no screen recording, no automation, no input monitoring
  beyond the event tap Accessibility already covers.
- An onboarding window or a tour. The menu bar is where the user notices the app is broken,
  so that is where the state lives; the settings window stays about preferences.
- Re-implementing System Settings deep links per OS version. One documented URL, and if it
  fails to open the app says where to click.

## Design

### The state is derived, never stored

Two facts decide everything: whether the process is trusted, and which tap the hotkey engine
actually got. `PermissionState` is computed from that pair and from nothing else, so it
cannot drift out of date the way a cached copy would.

| Trusted | Tap | State | Menu bar | What the menu says |
|---|---|---|---|---|
| no | none | `blocked` | warning icon | Accessibility is off — `Cmd+Tab` still belongs to macOS; **Grant Accessibility…** |
| yes | none | `blocked` | warning icon | macOS refused the event tap; relaunching is the only cure |
| yes | observe | `observing` | warning icon | the switcher can see `Cmd+Tab` but not take it over |
| yes | intercept | `intercepting` | plain icon | nothing |

`observing` is a real state, not an error: S04 already falls back to a listen-only tap when
interception is refused (secure input, another switcher). The user has to be told, because
the app looks installed and does nothing to `Cmd+Tab`.

### Asking once, then pointing

The first `Grant Accessibility…` shows the system prompt through
`AXIsProcessTrustedWithOptions`. macOS shows that prompt once per app, so every later request
opens System Settings › Privacy & Security › Accessibility directly. Which of the two the app
does is remembered for the session only — the prompt's own once-per-app rule is the system's
to keep, not ours to mirror on disk.

### Recovery without a relaunch

While the permission is missing, the app re-checks trust on a timer (two seconds — the check
is a local call, not IPC) and stops the moment it appears; on a fresh grant it rebuilds the
tap and repaints the menu bar. A tap that is merely observing is not retried on a timer:
secure input is the cause, and killing and rebuilding the tap every two seconds would cost
open sessions for nothing. That case is re-checked when the app becomes
active, and so is everything else: a permission revoked in System Settings turns the icon
back to the warning instead of leaving a switcher that silently does nothing.

## Definition of Done

- [ ] With Accessibility off, the menu bar shows a warning icon and a **Grant Accessibility…** item.
- [ ] Granting it starts interception within a couple of seconds, with no relaunch, and the icon goes back to plain.
- [ ] Revoking it turns the icon back to the warning the next time the app is activated.
- [ ] A tap that can only observe is reported as such, not as working.
- [ ] The prompt is asked for once; later requests open System Settings.
- [ ] The polling stops once the permission is granted, and never runs while it is present.
- [ ] The state derivation is unit-tested for all four trust/tap combinations.

## Test cases

| # | Case | Expected |
|---|------|----------|
| 1 | untrusted, no tap | `blocked`, needs attention, action is the prompt |
| 2 | trusted, no tap | `blocked`, needs attention, no prompt to offer |
| 3 | trusted, observing tap | `observing`, needs attention |
| 4 | trusted, intercepting tap | `intercepting`, no attention |
| 5 | start while blocked | engine started once, state published, poll armed |
| 6 | poll fires while still untrusted | state unchanged, poll armed again |
| 7 | poll fires after a grant | engine started again, `intercepting` published, poll not re-armed |
| 8 | start while trusted | no poll armed |
| 9 | first grant request | system prompt, not System Settings |
| 10 | second grant request | System Settings, not a second prompt |
| 11 | refresh after revocation | `blocked` published |

## Manual runbook

1. Revoke Accessibility for the app in System Settings, relaunch it → expected: warning icon,
   **Grant Accessibility…** in the menu, `Cmd+Tab` still shows the macOS switcher.
2. Choose **Grant Accessibility…** → expected: the system prompt appears the first time; the
   second time System Settings opens on the Accessibility list.
3. Tick the app in the list without relaunching → expected: within about two seconds the icon
   loses its warning and `Cmd+Tab` shows our ribbon.
4. Untick it, then click the menu bar icon → expected: the warning is back.
5. Hold `Cmd+Tab` inside a secure input field (a password field) → expected: the state reads
   as observing, not as working.

## Risks and open questions

- **Secure input is invisible to us.** We can only infer it from the tap we were given, so
  `observing` names the symptom and not the cause.
- **Trust changes are polled, not observed.** macOS has no notification for a granted
  Accessibility permission; two seconds is the compromise between latency and pointless work,
  and the timer only exists while the app is not working.
