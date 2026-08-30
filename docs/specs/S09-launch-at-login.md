# S09 — Launch at login

**Status:** agreed · **Depends on:** S08 · **ADRs:** —

## Goal

A switcher that has to be started by hand is not a switcher. The app registers itself as a
login item through `SMAppService`, shows the real state of that registration in the
settings window, and says what to do when macOS wants the user's approval.

## Non-goals

- A launch agent, a `LaunchAgents` plist, or anything written into `~/Library` by hand.
  `SMAppService.mainApp` is the supported route on macOS 13+ and needs no helper bundle,
  no privileged install and no entitlement.
- Starting hidden versus visible — the app is an accessory with no window at launch, so
  there is nothing to hide.
- Recovering from a bundle the user moved after registering — macOS invalidates the
  registration itself, and the settings window reports what it reads.

## Design

### The state is read, never remembered

Registration lives in the system, not in our preferences. Storing a copy would mean two
answers to the same question, and the system's answer is the one that matters: the user
can revoke a login item in System Settings without ever opening our window. So the
checkbox reflects `SMAppService.mainApp.status` every time the window opens, and the
preference file has no key for it.

`LoginItemStatus` maps the four system answers onto what the window has to do:

| Status | Checkbox | What the window says |
|---|---|---|
| `enabled` | on | nothing |
| `notRegistered` | off | nothing |
| `requiresApproval` | on | the item is waiting for approval in System Settings › General › Login Items |
| `notFound` | off, disabled | the bundle is not in a place macOS can register — move it to Applications |

`requiresApproval` is not an error: macOS has accepted the registration and is asking the
user to confirm it once. Showing it as "off" would invite a second registration that
changes nothing.

### Failure is reported, not swallowed

`register()` and `unregister()` throw. A throw means the checkbox goes back to what the
system says rather than to what the user clicked, and the log records it. The app has no
other way to tell the user, and silently drawing a checked box for a registration that did
not happen is the one outcome worth avoiding.

### The window follows the message

The message row is hidden while there is nothing to say, and the window resizes to the
form when the row appears. A status that changes while the window is open — the usual case,
since approval is asked for the moment the box is ticked — would otherwise be clipped by
the height the window was given when it opened.

## Definition of Done

- [ ] The settings window shows a login-item checkbox whose state comes from the system, not from our preferences.
- [ ] Turning it on registers the app; turning it off unregisters it; both survive a relaunch.
- [ ] `requiresApproval` reads as on, with a line telling the user where to approve it.
- [ ] A failed register or unregister leaves the checkbox showing the system's state and is logged.
- [ ] The status mapping is unit-tested for all four system answers.
- [ ] The Release bundle still declares zero entitlements and links no non-system library beyond `ServiceManagement`.

## Test cases

| # | Case | Expected |
|---|------|----------|
| 1 | status mapping, `enabled` | on, no message |
| 2 | status mapping, `notRegistered` | off, no message |
| 3 | status mapping, `requiresApproval` | on, approval message |
| 4 | status mapping, `notFound` | off, disabled, relocation message |
| 5 | toggling on, service succeeds | register called once, state re-read |
| 6 | toggling on, service throws | no crash, state re-read, failure logged |
| 7 | toggling off, service succeeds | unregister called once, state re-read |

## Manual runbook

1. Move the Release bundle to `/Applications`, launch it, open **Settings…** → expected:
   the login-item checkbox is off.
2. Turn it on → expected: macOS shows "Login item added"; the checkbox stays on; System
   Settings › General › Login Items lists Humane Space Tab.
3. Log out and back in → expected: the app is running, its menu bar item is present, and
   the checkbox is still on.
4. Turn it off, log out and back in → expected: the app does not start.
5. Run the bundle from a Downloads folder instead → expected: either it registers normally
   or the window says the bundle has to move, and nothing crashes.

## Risks and open questions

- **Ad-hoc signing.** Until S11 gives the app a stable signature, a rebuilt bundle is a
  different item to the system, and a registration made by yesterday's build may not
  survive today's. The runbook is run on one bundle from start to finish.
- **The approval notification is easy to miss.** The window's line is the fallback; a
  louder prompt belongs to S10, which owns permission UX.
