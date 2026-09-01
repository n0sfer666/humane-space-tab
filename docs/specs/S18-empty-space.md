# S18 — The empty Space

**Status:** agreed · **Depends on:** [S05](S05-switcher-state-machine.md), [S07](S07-overlay-ui.md), [S12](S12-front-application-windows.md) · **ADRs:** —

## Goal

A Space with nothing open on it answers the shortcut with the ribbon saying so, instead of
handing the key back to macOS and letting the system switcher appear. The promise the app
makes is that the shortcut belongs to the Space in front of you; a Space with no
applications is still that Space, and the answer "nothing here" is the app's to give.

## Non-goals

- No offer to open something. The ribbon says what is true and closes; it is not a launcher.
- No change to the window shortcut (S12). One window is still no choice at all: that
  shortcut keeps giving the key back, because there the front application's own switcher
  behaviour is a reasonable thing to fall through to.
- No new setting. There is nothing to configure about a sentence.

## Design

### Why the system switcher appears today

`CGEventTapHotkeySource` gives the key back when an activation opened nothing:

> An activation that opened nothing is not ours to keep: the key belongs to whatever is in
> front, and treating it as a pass-through is also what keeps the swallow policy honest —
> a press nobody swallowed leaves no unpaired release behind it.

That rule is right for the window shortcut and wrong for the application one. The fix is
not in the tap: an application session on an empty Space **does** open, so nothing is
handed back and the swallow policy stays paired. The tap keeps its rule unchanged.

### An empty session

`SwitcherSession` stops refusing an empty list when the scope is `.applications`:

| | Empty session |
|---|---|
| `selected` | `nil` — there is nothing to raise |
| `step` | does nothing; there is nowhere to move |
| `select(_:)` | refused, as it already is for an index out of range |
| commit | `.cancelled`, not `.committed` — the ribbon closes and nothing is activated |
| Escape | cancels, as always |

A `.frontWindows` session with an empty list is still refused, so S12 is untouched.

### What the ribbon shows

`OverlayModel` with no entries draws one line of text in the panel the profile describes —
same material, same corner radius, same padding — laid out by `OverlayLayout` as a single
slot wide enough for the sentence. The text is the app's own voice, in the interface
language (S19 translates it; until then it is English):

> **Nothing open on this Space**

The pointer has nothing to hover and nothing to click; the ribbon closes on the release of
the modifier like any other session.

## Definition of Done

- [ ] The shortcut on a Space with no applications shows the ribbon with its sentence, and
      the system switcher does not appear.
- [x] Releasing the modifier closes the ribbon and activates nothing.
- [x] Escape closes it, and Tab held down does not move anything or crash.
- [x] The window shortcut on the same Space still gives the key back.
- [x] The placeholder is drawn in the active profile's material, radius and padding.

## Test cases

| # | Case | Expected |
|---|------|----------|
| 1 | `SwitcherMachine.open([], .forward, scope: .applications)` | `.opened`, and the session is empty |
| 2 | `SwitcherMachine.open([], .forward, scope: .frontWindows)` | `.ignored` |
| 3 | Commit of an empty session | `.cancelled`, nothing activated |
| 4 | `step` on an empty session | `.ignored`, no crash |
| 5 | `OverlayLayout.compute(count: 0, …)` | a panel wide enough for the sentence, no slots |
| 6 | The tap on an empty Space | the key is swallowed: the session opened |

## Manual runbook

1. Make a Space with nothing open on it and press the shortcut → expected: the ribbon
   appears with "Nothing open on this Space", and macOS's own switcher does not.
2. Release the modifier → expected: the ribbon closes, nothing is raised, the Space is
   unchanged.
3. Press the shortcut and then Escape → expected: the ribbon closes at once.
4. Press the window shortcut on that Space → expected: nothing of ours appears.
5. Switch to a profile with a solid background and repeat step 1 → expected: the sentence
   is drawn in that profile's panel.

## Risks and open questions

- **A Space that only looks empty.** Attribution can fail and report no applications where
  some are open (S03). The ribbon would then claim an empty Space wrongly — but it claims
  it about the list it has, which is the same list the ribbon would have drawn from, so it
  is no more wrong than the ribbon already was.
