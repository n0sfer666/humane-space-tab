# S08 — Preferences & persistence

**Status:** agreed · **Depends on:** S03, S07 · **ADRs:** —

## Goal

Give the user the three choices the earlier specs deliberately postponed — which screen
the ribbon appears on, how long the gesture must be held before it appears, and whether
the private Space layer is used — and a native place to make them. Everything is stored
in `UserDefaults`, read once at launch and applied live, without a relaunch.

## Non-goals

- Editing the shortcut itself — S13. Recording a key combination is a separate machine
  with its own failure modes, and `Cmd+Tab` is the product's whole premise.
- Selecting a tile with the mouse — S14. It means giving the panel back the mouse events
  S07 explicitly took away, which is a change to the panel, not a preference.
- Launch at login — S09, which owns `SMAppService`.
- Making the ribbon list windows instead of applications — S16. This spec defines the
  preference that gates it, and nothing more: what the ribbon lists is a change to the
  inventory, the order, activation and the panel, not a setting.
- Syncing preferences anywhere. The app has no network code (S00), and the guard test
  enforces it.

## Design

### The model is a value, and it distrusts what it reads

`Preferences` is a plain value in `SwitcherCore`: reveal delay, overlay screen, private
layer. Its initialiser normalises rather than validates — the delay is clamped into
0…500 ms, a non-finite one falls back to the default, and an unknown screen raw value
decodes to the default. The store is a file the user can edit by hand, so a nonsense
value must produce a working app with a default, never a wedged one.

The delay is also quantised to **10 ms** steps, so the number the slider shows, the
number on disk and the delay the overlay waits are the same value. Without it the label
rounds one way and the app uses another, and a settings window that lies about the
setting is worse than no settings window.

Defaults: reveal delay **120 ms** (S07's constant), screen **with keyboard focus**
(S07's `NSScreen.main`), private layer **off** (S03's conservative default). The
defaults are the behaviour that shipped before this spec, so a fresh install changes
nothing.

### The centre is the seam

`PreferencesCenter` holds the current value, hands it out, and notifies observers when it
changes — and only when it actually changes, so re-selecting the same popup item does not
churn the overlay. It persists through an injected closure, the way `SwitcherCoordinator`
takes `activate:`, which keeps the pure module free of the store.

Two consumers subscribe: the overlay controller takes the delay, the window surface takes
the screen choice. Both are on the main actor already.

### Windows of one application

Windows and Linux switch between windows; macOS switches between applications, and the
ribbon is built on the second model — S05's MRU order, S06's activation and S07's one
icon per application all follow from it. People who came from the other model want the
first, so it becomes a preference, **off by default**: the default has to be what macOS
itself does, and a switcher that suddenly lists four windows of one editor where the
system lists one icon has stopped being the thing its user reached for.

The key is defined here; the behaviour behind it is not. Listing windows changes what the
inventory returns, what the MRU orders, what activation raises and what the panel draws —
four specs' worth of consequences, which is what S16 is for. S16 has since shipped, so the
key now has both a reader and a checkbox; until it did, neither existed, because a toggle
that toggles nothing is a settings window that lies.

### Storage

| Key | Type | Default |
|---|---|---|
| `RevealDelay` | seconds, `Double` | 0.12 |
| `OverlayScreen` | `String` — `focused` / `pointer` | `focused` |
| `PrivateSpaceLayerEnabled` | `Bool` | `false` |
| `WindowSwitchingEnabled` | `Bool` | `false` — the behaviour behind it is S16's |

The third key is the one S03 already writes, kept verbatim: a user who turned the private
layer on before this spec must not silently lose that choice. A missing key means the
default, so an untouched installation stores nothing at all.

`SpaceLayerPreference` keeps reading `UserDefaults` directly rather than going through the
centre — it is consulted from the inventory path, which is not main-actor-bound, and
`UserDefaults` is already thread-safe. The key name is shared between the two readers, so
there is one spelling of it in the code.

### The window

An ordinary titled `NSWindow` opened from the menu bar's **Settings…** item, with one
control per preference and a line of explanation under the private-layer checkbox — the one setting with
a real trade-off (S03: the private layer is accurate but undocumented, the public one is
documented but blind to minimised windows). The app is an accessory (`LSUIElement`), so
opening the window activates it explicitly; closing it releases nothing, the controller is
reused.

Changing a control writes through the centre immediately. There is no OK/Cancel: a
preference window that needs confirmation is a dialog pretending to be a preference
window.

## Definition of Done

- [ ] The four preferences round-trip through `UserDefaults`, and a missing key reads as the documented default.
- [ ] A hand-edited nonsense value (negative, huge, non-finite, unknown string) yields the default, never a broken overlay.
- [ ] The delay the window shows is the delay the overlay uses, to the millisecond.
- [ ] Changing the delay changes when the ribbon appears, without a relaunch.
- [ ] Changing the screen moves the ribbon to the screen with the pointer and back.
- [ ] The private-layer toggle reads and writes the key S03 already uses.
- [ ] Observers are notified on a real change and not on a re-set of the same value.
- [ ] The Settings window opens from the menu bar, closes, and reopens.
- [ ] The whole suite is green; `swift-format --strict` and `swiftlint --strict` are clean.
- [ ] The Release bundle still declares zero entitlements and links no non-system library.

## Test cases

| # | Case | Expected |
|---|------|----------|
| 1 | preferences, delay below zero / above the cap | clamped to the range |
| 2 | preferences, non-finite delay | the default |
| 3 | preferences, unknown screen raw value | the default |
| 3a | preferences, a delay between steps | quantised to 10 ms |
| 4 | store, all keys missing | the documented defaults |
| 5 | store, values written then read back | identical value |
| 6 | store, a nonsense delay on disk | normalised on load |
| 7 | centre, update with a different value | observers notified once, value persisted |
| 8 | centre, update with the same value | no notification, no write |
| 9 | centre, observer added after an update | sees the current value |
| 10 | controller, delay changed while idle | the next session uses the new delay |
| 11 | screen resolver, `focused` | the screen with keyboard focus |
| 12 | screen resolver, `pointer` on a single display | that display |
| 12a | screen resolver, neither signal available | the primary display, never nothing |

## Manual runbook

1. Launch the Release bundle, open **Settings…** from the menu bar item → expected: the
   window appears in front and the app is active.
2. Set the delay to its maximum, hold `Cmd+Tab` → expected: the ribbon appears noticeably
   later; set it to zero → expected: it appears at once, even on a quick tap.
3. With two displays, set the screen to *with the pointer*, move the pointer to the second
   display and hold `Cmd+Tab` → expected: the ribbon appears there.
4. Toggle the private layer, then switch on a Space with a minimised window → expected: the
   behaviour matches the S03 runbook for that layer.
5. Quit and relaunch → expected: every choice survived.

## Risks and open questions

- **A zero delay makes every quick tap flash the ribbon.** That is the user's choice, and
  the reason the slider is labelled in milliseconds rather than named "instant".
- **The pointer screen is resolved when the session opens**, not continuously; moving the
  pointer mid-gesture does not move the ribbon. Continuous tracking would need the mouse
  events S07 gave up.
- **The window-switching preference is a promise this spec cannot keep alone.** It is
  written down here so the default — off — is decided before the feature is designed, and
  so S16 inherits a decision instead of making one under implementation pressure.
- **A window with three controls invites more.** Every future preference has to justify
  itself against the product goal of nativeness — the settings window is not the place to
  park indecision.
