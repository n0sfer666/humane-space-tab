# S13 — Shortcut editor

**Status:** agreed · **Depends on:** S04, S08, S10 · **ADRs:** —

## Goal

Let the user replace `Cmd+Tab` with a combination of their own, record it by typing it,
and refuse the combinations the design cannot honour — with the reason said out loud.
The choice is stored beside the other preferences and applied without a relaunch.

## Non-goals

- **Shortcuts without a modifier.** The whole gesture is *hold a modifier, tap a key*: the
  session commits when the modifier is released (S04, S05). A bare `F19` has nothing to
  release, so it would need a second interaction model rather than a preference. The
  recorder refuses it and says why.
- **A second shortcut.** One activation, one reverse direction (`+Shift`). Separate
  bindings for other gestures belong to the specs that add those gestures (S12+).
- **Per-application shortcuts.** Nothing in the switcher is scoped to an application.
- **Discovering which shortcuts macOS has reserved.** There is no public API for the
  system's own hotkey table, and the private one is not worth the S00 budget. A short
  blocklist covers the destructive cases; everything else is the user's call.

## Design

### Validation is a pure decision in the core

`ShortcutRule` answers one question — may this combination be the activation? — and it
answers it in `SwitcherCore`, where it can be tested without a window. The rejections are
a closed enum, so every refusal the UI can show has a name:

| Rejection | Why |
|---|---|
| `noModifier` | nothing to hold, so the session could never commit |
| `containsShift` | `+Shift` **is** the reverse direction (S04); an activation that already contains Shift has no backward gesture and would look broken |
| `escape` | Escape cancels an open session (S05), and `Cmd+Option+Esc` is the only way out of a wedged application |
| `reserved` | `Cmd+Q` and `Cmd+W` — a switcher that quits or closes the front window on every press is not recoverable by the user who set it |
| `modifierKey` | a modifier's own key code (54–63) arrives as a modifier change and never as a press, so a shortcut armed on one could never fire |

Shift is refused rather than tolerated because S04 decided this explicitly: *"S08 should
refuse to record one rather than let it look broken."* This spec is where that promise is
kept.

The blocklist is deliberately two entries long. A longer one would pretend to know what
the system has reserved, and would age badly; these two are on it because their damage is
immediate and repeats on every keypress.

Beside the rule there is a normalisation. The stored shortcut is a file the user can edit
by hand, so modifier bits this app gives no meaning to are dropped before the rule sees
them, and whatever fails the rule afterwards decodes to the default. Both halves exist for
the same reason: a hand-edited value must produce a working app, never a combination
nobody can press.

### Recording is a state machine, not a view

`ShortcutRecording` in the core takes key strokes and returns one of *incomplete*
(modifiers only, keep waiting), *rejected* (with the reason), or *recorded*. The AppKit
control feeds it events and renders what it returns; it holds no rules of its own. This is
the same split as `HotkeyInterpreter` and `CGEventTapHotkeySource` in S04.

A rejection keeps the control recording. The user pressed something; the honest response
is to say why it will not do and let them press something else, not to drop out of the
mode and make them click again. Escape on its own is the way out — it *cancels* recording
and leaves the shortcut alone, which is why Escape with modifiers is a rejection rather
than a fifth outcome.

### Recording needs its own tap

While the recorder has focus, the switcher's tap is stopped and a second, short-lived tap
takes its place: same `cgSessionEventTap` at `headInsertEventTap`, same Accessibility
permission, keyDown and flagsChanged only, swallowing what it sees.

It has to be a tap and not `keyDown` on the view. macOS handles its own `Cmd+Tab` in the
window server, before the event reaches an application, so a recorder built on ordinary
key events could never record `Cmd+Tab` — the one combination this app exists to take
over. The tap is what puts us ahead of the window server, and it is the reason the app
already needs Accessibility at all.

The two taps never run at once, and that is enforced by the one object that owns the
switcher's tap. `PermissionCenter` already stops and rebuilds it on activation, on a
revoked permission and on a two-second poll; if the recorder stopped the engine behind its
back, any of those could put the switcher's tap back mid-recording — it would be inserted
later at the same `headInsertEventTap`, sit ahead of the recorder and swallow the very
combination being typed. So the recorder asks the centre to `suspend`, and a suspended
centre refuses every rebuild until `resume`. `HotkeyEventTap` — the creation and run-loop
wrapper S04 already has — is reused, so the second tap is a callback and a lifetime, not a
second copy of the machinery.

The outcome leaves the tap one run-loop turn late, and only after the release of the key
that produced it has been swallowed too. Both halves matter. Delivering it inside the
callout would tear down the very Mach port whose callback is on the stack and create two
more taps while the window server waits on this one; and a press swallowed without its
release leaves an unpaired key-up at whatever application is in front — the invariant S04's
`SwallowPolicy` keeps, kept here as well.

Without Accessibility the recording tap cannot be created. The control then says so and
offers the same **Grant Accessibility…** button S10 owns — the action, not a sentence
about where to find it — rather than sitting there capturing nothing.

While recording, the tap swallows every key press on the machine, so the way out is named
on screen: the caption reads *Press Escape to cancel* for as long as the mode is on.

### Applying the change

`InterceptingHotkeyEngine` builds its source through a factory closure and drops it on
`stop()`, so `stop()` followed by `start()` is a rebuild. The observer that already reacts
to preference changes gains one more consumer: a changed shortcut asks the permission
centre to rebuild the tap, and the factory reads the current shortcut when it constructs
it. The intercept → observe fallback runs again on the way, which is correct — permission
may have changed since launch.

A shortcut recorded in the window changes the preference *before* the recording ends, so
the rebuild request lands while the tap is still suspended and does nothing; the tap that
comes back on `resume` is already built from the new shortcut. One tap is created per
recording, not three.

`Shortcut.commandTab` stops being a default parameter of `CGEventTapHotkeySource`. A
default that silently disagrees with the stored preference is the kind of bug that only
shows up in the one build nobody tested.

### Storage and display

| Key | Type | Default |
|---|---|---|
| `ShortcutKeyCode` | `Int` — virtual key code | 48 (`Tab`) |
| `ShortcutModifiers` | `Int` — `ModifierSet` raw value | 1 (`Command`) |

Either key missing means the default. A stored pair that fails `ShortcutRule` decodes to
`Cmd+Tab`, the same way S08 normalises a nonsense delay: the store is a file the user can
edit, and a hand-edited nonsense value must produce a working app.

The label is built from the modifier glyphs in the native order — `⌃⌥⇧⌘` — followed by the
key's name. Keys with a stable glyph (`⇥`, `␣`, `↩`, arrows, `F1`–`F20`) come from a table
in the core. Everything else is asked of the current keyboard layout through a
`KeyNaming` port, implemented in `SystemAdapters` with `UCKeyTranslate`: on an AZERTY
layout the key next to `A` must read `Q` if that is what is printed on it. Carbon is a
system framework, so the bundle check in S11 is unaffected.

### In the window

One row in the existing settings form: the recorder control and a **Restore default**
button beside it, plus the rejection reason under it while recording. The control is its
own file — `PreferencesFormView` is already near the size limit, and a focusable control
with a recording mode is a separate responsibility from a form that lays out rows.

## Definition of Done

- [ ] The shortcut round-trips through `UserDefaults`; a missing key reads as `Cmd+Tab`.
- [ ] A stored combination that fails the rules decodes to `Cmd+Tab` rather than breaking the switcher.
- [ ] A shortcut with no `⌘`/`⌥`/`⌃`, one containing Shift, one using Escape, and `⌘Q` / `⌘W` are each refused with their own reason.
- [ ] Recording captures `Cmd+Tab` itself, without the system switcher appearing.
- [ ] While recording, the switcher's own shortcut does not open the ribbon.
- [ ] A recorded shortcut takes effect without a relaunch, and the previous one stops working.
- [ ] `+Shift` reverses the direction of whatever shortcut is current.
- [ ] **Restore default** returns to `Cmd+Tab` and applies at once.
- [ ] Without Accessibility, the recorder says so instead of capturing nothing.
- [ ] The label matches the keys pressed, including on a non-US layout.
- [ ] The whole suite is green; `swift-format --strict` and `swiftlint --strict` are clean.
- [ ] The Release bundle still declares zero entitlements and links no non-system library.

## Test cases

| # | Case | Expected |
|---|------|----------|
| 1 | rule, `⌥Tab` | accepted |
| 2 | rule, `Tab` alone | rejected, `noModifier` |
| 3 | rule, `⌘⇧Tab` | rejected, `containsShift` |
| 4 | rule, `⌘⌥Esc` | rejected, `escape` |
| 5 | rule, `⌘Q` and `⌘W` | rejected, `reserved` |
| 6 | rule, `⌃⌥Space` | accepted |
| 7 | recording, modifiers only | incomplete, still recording |
| 8 | recording, a rejected stroke | rejected with the reason, still recording |
| 8a | recording, bare Escape | cancelled, the shortcut unchanged |
| 9 | recording, `⌘Tab` | recorded |
| 10 | preferences, no shortcut stored | `Cmd+Tab` |
| 11 | preferences, a stored `⌘⇧Tab` | normalised to `Cmd+Tab` |
| 12 | store, written then read back | identical shortcut |
| 13 | centre, shortcut changed | observers notified once, value persisted |
| 14 | interpreter, a non-default shortcut | forward on it, backward on it `+Shift`, nothing on the old one |
| 15 | formatter, `⌃⌥⇧⌘` with `Tab` | `⌃⌥⇧⌘⇥`, in that order |
| 16 | formatter, a key with no glyph | the name the layout gives it |
| 17 | rule, a modifier's own key code | rejected, `modifierKey` |
| 18 | rule, modifiers carrying an unknown bit | normalised, the bit dropped |
| 19 | recorder tap, a press | held; the outcome arrives only after the release |
| 20 | recorder tap, a release with no swallowed press | passed through |
| 21 | suspension, stop without start | the tap is not started |
| 22 | centre, refresh while suspended | the tap stays down |
| 23 | view, a rejected stroke | still recording, nothing adopted |

## Manual runbook

1. Open **Settings…**, click the recorder, press `⌥Tab` → expected: the field shows `⌥⇥`,
   the reason line is empty, recording ends.
2. Hold `⌥` and tap `Tab` → expected: the ribbon appears and cycles. Hold `⌘` and tap
   `Tab` → expected: the system switcher, because the shortcut is no longer ours.
3. Hold `⌥` and tap `⇧Tab` → expected: the selection moves backwards.
4. Click the recorder and press `⌘⇧Tab` → expected: refused, with the Shift reason, still
   recording; press `Escape` → expected: recording ends, the shortcut is unchanged.
5. Click the recorder and press `⌘Tab` → expected: it is recorded, and the system switcher
   does **not** appear while recording.
6. **Restore default**, then hold `⌘Tab` → expected: our ribbon again.
7. Revoke Accessibility, reopen Settings, click the recorder → expected: it says the
   permission is missing and shows a **Grant Accessibility…** button that opens the same
   prompt the menu bar item does.
8. Quit and relaunch → expected: the recorded shortcut survived.

## Risks and open questions

- **A user can bind something the system also owns.** `⌘Space` will fight Spotlight, and we
  cannot tell them so without private API. The blocklist stops the destructive cases; the
  rest is a choice they can undo in the same window.
- **The recording tap is a second thing that can fail to install.** It fails exactly when
  the switcher's own tap would — no permission — so there is one failure to explain, not
  two, and the control explains it.
- **Restarting the engine re-runs the fallback.** A shortcut change can therefore move the
  app from intercept to observe mode if permission was revoked meanwhile. That is honest
  behaviour, and S10 already makes the mode visible.
- **Layout-dependent labels drift.** A shortcut recorded on one layout keeps its virtual
  key code and will be labelled by whatever the current layout prints there — the same
  behaviour as the system's own shortcut list.
