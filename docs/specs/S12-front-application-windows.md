# S12 — Windows of the front application

**Status:** agreed · **Depends on:** S03, S04, S05, S07, S13, S16 · **ADRs:** —

## Goal

``Cmd+` `` cycles the windows of the application in front. macOS has had it for years, and it
has the same blind spot its `Cmd+Tab` has: it counts windows on every Space at once, so a
gesture meant to move between two documents on this desk can throw the user onto another
one. S12 is the same gesture with the app's rule applied — **this Space only** — behind a
second shortcut the user can change.

Everything it needs exists after S16: the window list, the stacking order, the titles, the
accessibility raise. What is new is a second way in, and a session that knows which way it
came in by.

## Non-goals

- **Windows on other Spaces, and minimised ones.** They are exactly what the system
  shortcut gets wrong. A window that is not on this Space is not in this list, which also
  means ``Cmd+` `` never switches Space and never un-minimises anything.
- **Switching scope mid-session.** With the ribbon open on one shortcut, the other one is
  swallowed and does nothing. Nesting the two gestures — `Cmd+Tab` to an application, then
  `` ` `` to walk its windows — is a third interaction model, not a preference; it is the
  next spec's problem if it is anyone's.
- **Following `WindowSwitchingEnabled`.** S16's preference decides what `Cmd+Tab` lists.
  This shortcut lists windows because that is what it is for, on or off.
- **App Exposé, Mission Control, hide and minimise.** Still later specs.

## Design

### Two shortcuts, one grammar

The gesture is unchanged: hold a modifier, tap a key, release to commit, `+Shift` to
reverse, Escape to cancel (S04, S05). What the second shortcut changes is *what the session
lists*, so it travels as a scope on the command rather than as a second machine:

```
activate(direction, scope)   scope ∈ { applications, frontWindows }
```

`ShortcutSet` holds both bindings and answers one question for the interpreter — which
scope, if any, does this stroke arm? The applications shortcut is tried first, so two
bindings that collide (only reachable by hand-editing the store) resolve to the older
gesture instead of to nothing.

While a session is open the interpreter looks at **one** shortcut: the one that opened it.
That is why the session carries its scope. Without it, releasing `Cmd` would be read
against the wrong binding, and a ``Cmd+` `` session held open with a shortcut that has no
`Cmd` in it would commit at the wrong moment.

### What the ribbon lists

The front application is the head of the MRU order — the list S05 already maintains from
activation notifications, seeded from the front-to-back application list. It is a fact the
session build has in hand; asking `NSWorkspace` again would be a second answer to a
question already answered, and a slower one.

Its windows are filtered to the ones this Space holds — `onCurrentSpace` from S03, with no
`visibility != .onScreen` escape hatch, which is precisely how this list differs from
S16's — and ordered by the live stacking order, exactly as S16 orders its own. Forward
therefore selects the window immediately behind the front one, which is what a single tap
should do.

The ranking is the same code in both places: `StackingOrder` takes the front-to-back list
and sorts entries by it, appending what it cannot place. S16 keeps its rule about which
windows are listed; S12 keeps its own; the sort they share is written once.

### Nothing to cycle, so the key is not ours

One window, or none, means the gesture has no work. The user decided this passes through:
``Cmd+` `` then does whatever it would have done without us — the system's own window cycling,
or the application's own binding, which is a real one in terminals and editors.

The tap already computes the decision before it swallows, so the rule is one question asked
after the command is emitted: *did a session actually open?* If not, the stroke is treated
as a pass-through, which also keeps `SwallowPolicy`'s invariant — a key-down that was not
swallowed leaves no swallowed key-up behind it, and no application sees half a keystroke.

The coordinator is where "no work" is decided: fewer than two entries in the `frontWindows`
scope opens nothing. The `applications` scope keeps S05's behaviour, where an empty list
already opens nothing and now passes the key on rather than eating it.

### Recording it

S13's recorder is reused as-is, twice, with two differences it did not need when it was
alone: each row restores its **own** default, and a combination already bound to the other
gesture is refused with its own reason rather than silently stealing it. The rejection is
`taken`, and it is in `ShortcutRule` with the rest — the view asks the rule, it does not
know the rule.

The two rows share the one recording tap. Only the focused row records, only one row can
have focus, and the row that ends a recording is the row that started it, so the suspension
protocol of S13 is untouched.

The settings form grows past the size a form should be, so the shortcut rows move into
their own view. A grid that lays out preferences and a pair of recorders that validate each
other are two responsibilities.

### Storage

| Key | Type | Default |
|---|---|---|
| `WindowShortcutKeyCode` | `Int` — virtual key code | 50 (`` ` ``) |
| `WindowShortcutModifiers` | `Int` — `ModifierSet` raw value | 1 (`Command`) |

Either key missing means the default, and a stored pair that fails `ShortcutRule` decodes
to ``Cmd+` ``, the same normalisation S13 already applies to the first shortcut. A pair that
collides with the applications shortcut is left alone rather than rewritten: the
interpreter's fixed precedence already makes the outcome deterministic, and rewriting a
value the user typed into the file would be a second, silent rule.

Key code 50 is the key **left of `1`** on an ANSI layout, and is what macOS itself binds.
On a layout that prints something else there, the label follows the layout (S13) and the
user can record another key — which is the argument for making this a preference at all.

### Permissions and privacy

Nothing new. The windows come from the same window-server call, the titles from the same
accessibility path with the same 50 ms timeout, the raise from the same `kAXRaiseAction`,
and none of it is reachable without the Accessibility grant the switcher already needs.
Titles are still drawn and never logged, never persisted.

## Definition of Done

- [ ] ``Cmd+` `` opens the ribbon on the front application's windows on this Space, ordered
      front to back, and releasing `Cmd` raises the selected one. — the list, its order and
      the commit target are tested; the raise on a live desktop is runbook steps 1–2.
- [x] No window of another Space and no minimised window ever appears in that list.
- [x] ``Cmd+Shift+` `` walks it backwards; Escape cancels it; the reveal delay applies —
      the session is the same one S07 already reveals.
- [x] With one window or none, the key reaches the application underneath and the ribbon
      never appears.
- [x] `WindowSwitchingEnabled` changes nothing about this shortcut.
- [x] The shortcut is recordable, refuses the combination already bound to `Cmd+Tab` with
      its own reason, restores to ``Cmd+` ``, and survives a relaunch — the refusal and the
      stored pair are tested, the button and the relaunch are runbook steps 8–10.
- [ ] Both shortcuts work after either is changed, without a relaunch. — the tap is rebuilt
      from the pair; the live rebuild is runbook step 8.
- [x] While one ribbon is open, the other shortcut does not open a second one.
- [x] No title reaches the log; no new permission is requested.
- [x] The whole suite is green; `swift-format --strict` and `swiftlint --strict` are clean.
- [x] The Release bundle still declares zero entitlements and links no non-system library.

## Test cases

| # | Case | Expected |
|---|------|----------|
| 1 | set, a stroke matching the applications shortcut | `applications` scope, forward |
| 2 | set, a stroke matching the windows shortcut | `frontWindows` scope, forward |
| 3 | set, the same stroke `+Shift` | the same scope, backward |
| 4 | set, both shortcuts equal | the applications scope wins |
| 5 | interpreter, idle, the windows shortcut | `activate(.forward, .frontWindows)` |
| 6 | interpreter, a `frontWindows` session, its own key | `step` |
| 7 | interpreter, a `frontWindows` session, the other shortcut's key | consumed, no command |
| 8 | interpreter, a `frontWindows` session, its modifier released | `commit` |
| 9 | cycle, three windows of the front app, one on another Space | two entries, stacking order |
| 10 | cycle, a minimised window | absent |
| 11 | cycle, the front app has one window | no entries opened, `.ignored` |
| 12 | cycle, windows the stacking list does not name | appended, in inventory order |
| 13 | coordinator, `frontWindows` with fewer than two entries | nothing opens |
| 14 | coordinator, `frontWindows` with two | opens, scope recorded on the session |
| 15 | tap, an activate that opened nothing | the stroke passes through |
| 16 | tap, an activate that opened a session | the stroke is swallowed |
| 17 | tap, the release of a passed-through press | passes through too |
| 18 | rule, a shortcut equal to the other one | rejected, `taken` |
| 19 | preferences, no window shortcut stored | ``Cmd+` `` |
| 20 | preferences, a stored window shortcut that fails the rules | ``Cmd+` `` |
| 21 | store, both shortcuts written then read back | identical |
| 22 | recorder, a recorded duplicate | refused with the reason, still recording |
| 23 | recorder, **Restore default** on the window row | ``Cmd+` ``, not `Cmd+Tab` |

## Manual runbook

1. Open three windows of one application on one Space, hold `Cmd` and tap `` ` `` →
   expected: the ribbon lists exactly those windows, the second one selected.
2. Release `Cmd` → expected: that window comes forward; the application does not change.
3. Move one of the windows to another Space, repeat → expected: it is not in the list, and
   the gesture never switches Space.
4. Minimise one window, repeat → expected: it is not in the list.
5. Focus an application with a single window and tap ``Cmd+` `` → expected: no ribbon, and the
   application's own ``Cmd+` `` behaviour happens (in Terminal, a new window).
6. ``Cmd+Shift+` `` on an application with three windows → expected: the selection walks
   backwards.
7. Hold `Cmd`, tap `Tab` to open the application ribbon, then tap `` ` `` → expected: the
   ribbon keeps cycling applications and nothing else happens.
8. In **Settings…**, record ``⌥` `` for the window shortcut → expected: it is accepted, and
   ``⌥` `` cycles windows while ``Cmd+` `` no longer does.
9. Record `⌘Tab` for the window shortcut → expected: refused, with the reason that it is
   already the other shortcut.
10. **Restore default** on that row, quit and relaunch → expected: ``Cmd+` `` again, and both
    shortcuts still work.

## Risks and open questions

- **The front application is the MRU head, not a fresh question to the system.** If the
  order were ever stale — an activation notification missed — the ribbon would list the
  wrong application's windows. The same head already decides where `Cmd+Tab` starts, so a
  drift would be visible long before this spec noticed it.
- **A pass-through is indistinguishable from a broken shortcut.** A user whose front
  application has one window sees nothing happen twice and may conclude the feature is off.
  The alternative — a ribbon with one entry that cannot move — is worse, and the decision
  was made deliberately.
- **`` ` `` is not where it is printed on every layout.** The default follows macOS's own
  choice of key code; the recorder is the answer for everyone else.
