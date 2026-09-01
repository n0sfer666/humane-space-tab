# S17 — Appearance & profiles

**Status:** agreed · **Depends on:** [S07](S07-overlay-ui.md), [S08](S08-preferences.md) · **ADRs:** —

## Goal

The ribbon's looks become the user's: icon size, the space around them, a frame, the
material behind them, whether the row turns as a carousel, and how the selection is told
apart from the rest. The settings are kept in named profiles — the built-in one plus up
to five of the user's own — and every number is a slider with a field beside it, bounded
so that no combination can produce a ribbon that does not fit or a frame that leaves it.

## Non-goals

- No per-application or per-Space appearance: a profile is global, switched by hand.
- No colour picker beyond what the three background styles need — the ribbon takes its
  colours from the system, which is what makes it look native.
- No import/export of profiles as files. The store is `UserDefaults`, as in S08.
- No new gesture. Switching profiles happens in the settings window, not from the ribbon.

## Design

### Where it lives

The settings window becomes an `NSTabViewController` in the toolbar style macOS System
Settings uses: **General** (everything S08 already has) and **Appearance** (this spec).
A tab, not a second window: the window already exists, and a preview that opens beside
its own settings is easier to judge than one in a window of its own.

### The model

Pure values in `SwitcherCore`, so the arithmetic is testable without AppKit:

| Type | What it holds |
|---|---|
| `Appearance` | one complete look: icon size, ribbon padding, gap, frame, background, carousel, selection preset |
| `AppearanceLimits` | the bounds of every number **given the others**, and the normalisation that clamps a value into them |
| `AppearanceProfile` | a name and an `Appearance` |
| `AppearanceBook` | the built-in profile, up to five of the user's, and which one is active |

`OverlayMetrics` (S07) stops carrying its own constants and is derived from an
`Appearance`, so the ribbon has one source of truth and the preview and the real panel
cannot drift apart.

### Bounded, and bounded against each other

Every number is a slider with a field: the slider for the feel of it, the field for a
value the user knows. Both write the same clamped number, and the field commits on Enter
or on losing focus, never mid-typing.

The bounds are not fixed constants but functions of the rest of the look — this is the
interlocking the feature is asked for:

- **Icon size** 16–128 pt, and never more than a quarter of the narrowest screen's width:
  the icon is a ceiling anyway — a crowded ribbon shrinks below it to fit (S07) — so what
  is bounded here is the size a person would otherwise be handed on a small display.
- **Ribbon padding** and **gap** are shares of the icon, and they share one budget: the
  spacing of a ribbon — both margins plus every gap — may not take more room than half the
  icons in it. Widening the gaps is what leaves the margin less to grow into, and the other
  way round.
- **Frame padding** 0–40 % of the icon, and never more than the ribbon padding minus the
  frame's own width — a frame cannot reach outside the panel that draws it.
- **Frame width** 0–4 pt, **corner radius** 0–40 pt.

`AppearanceLimits` answers what a control may offer right now — `iconSize(_:screenWidth:)`,
`paddingShare(_:)`, `gapShare(_:)`, `framePaddingShare(_:)` — and `normalise` brings a
stored look inside all of them at once. The UI asks on every change and re-bounds the other
controls, so an impossible combination cannot be expressed rather than being corrected after
the fact.

### Background

Three styles, each with only what it can meaningfully carry:

| Style | Adjustable | Notes |
|---|---|---|
| `glass` | scrim 0–40 % | the S07 material: Liquid Glass on macOS 26, HUD blur below |
| `transparent` | opacity 0–100 % | no material; the desktop shows through the panel |
| `background` | opacity 0–100 % | a solid panel in the system's window background colour |

### The carousel

Off, and the ribbon holds every entry still and shrinks to fit. On, and the row turns
under a stationary selection as S07 describes, with one number exposed: the number of
slots, 5–12. Nothing else about the carousel is open — the turning point is what makes it
read as one row rather than a jump.

### Telling the selection apart

Presets, not free-form: a preset is a named set of numbers, and the ones that ship are

| Preset | Selected | The rest |
|---|---|---|
| `native` | as macOS draws it: same size, a rounded highlight behind it | full colour |
| `enlarged` | 1.2× | dimmed to 62 % — S07's current look, and the default |
| `spotlight` | 1.3× | dimmed to 35 % and shrunk to 0.9× |
| `framed` | framed, not scaled | full colour |

### Profiles

The built-in profile is always there and cannot be renamed, edited or deleted: while it
is active the Appearance controls are disabled, and **Duplicate** makes an editable copy.
Beyond it the user keeps up to five, each named; **New**, **Duplicate**, **Rename** and
**Delete** act on the list, and deleting the active one falls back to the built-in.

Editing a control writes into the active profile at once — there is no Save button, as
in S08, and the ribbon uses the change on its next session.

### The preview

A button opens a sheet with a count — 1, 2, 3, 5, 10, 20, 50, 100 — and a **Show**
button. Showing runs a four-second demonstration in the sheet: the ribbon drawn with that
many placeholder entries, its selection advancing once a second. It is the same
`OverlayContentView` the panel uses, in a view of its own, so what the sheet shows is what
the gesture will show; it never opens the panel, so it cannot disturb the Space.

### Delivery

Five stages, each verified on the machine before the next: **1** the tab and profiles;
**2** the metrics; **3** the background; **4** the carousel and presets; **5** the preview.

## Definition of Done

- [x] The settings window has General and Appearance tabs, and General behaves exactly as before.
- [x] A look is stored per profile: the built-in one plus at most five, each with a name the user can change.
- [x] The built-in profile cannot be edited, renamed or deleted, and duplicating it produces an editable copy.
- [x] Deleting the active profile leaves the built-in one active, and the ribbon keeps working.
- [x] Profiles survive a relaunch, and a store edited into nonsense by hand yields the built-in profile rather than a broken window.
- [x] Every number has a slider and a field showing the same value, and neither can leave the range the other settings allow.
- [x] No combination of settings gives a ribbon more spacing than icons, or a frame outside the panel.
- [x] Each background style offers only what it can carry, and the ribbon draws in that style.
- [x] The carousel can be switched off, and with it off the row holds still and shrinks to fit.
- [ ] Each selection preset is visible in the ribbon, and `native` matches what macOS draws.
- [x] The preview shows 1, 2, 3, 5, 10, 20, 50 and 100 entries, advancing the selection once a second for four seconds.
- [x] Changing a setting is used by the next session without a relaunch.

## Test cases

| # | Case | Expected |
|---|------|----------|
| 1 | `AppearanceLimits` with the gaps at their widest | the margin's range shrinks by what the gaps took |
| 2 | Frame padding raised above the ribbon padding | clamped to ribbon padding minus frame width |
| 3 | A number outside its range, as if edited by hand in the store | normalised into the range, never rejected |
| 4 | Six profiles added | the sixth is refused, five kept |
| 5 | The built-in profile edited | unchanged; the edit is refused |
| 6 | Duplicating the built-in profile | a new editable profile with the same look and a name of its own |
| 7 | The active profile deleted | the built-in one becomes active |
| 8 | A profile renamed to an empty name | the previous name is kept |
| 9 | Store holding malformed JSON | the built-in book, no crash |
| 10 | `OverlayMetrics` derived from each preset | the documented scale and dimming for each |
| 11 | Carousel off with twenty entries | one row, every entry present, icons shrunk |
| 12 | Preview at 100 entries | the layout matches what a session with 100 entries would draw |
| 13 | Preview run | four steps, one per second, then it ends by itself |

## Manual runbook

1. Open Settings → Appearance → expected: the built-in profile is active and its controls are disabled.
2. Duplicate it, rename the copy → expected: the controls come alive, the name shows in the list.
3. Drag the gap to its maximum → expected: the margin slider loses the range the gaps took, and no field can be typed past it.
4. Set a frame and raise its padding → expected: the frame stays inside the panel at every value.
5. Switch through the three backgrounds → expected: the ribbon changes material at the next gesture, and each style shows only its own controls.
6. Switch the carousel off, then hold the shortcut on a Space with a dozen applications → expected: one still row with every application on it.
7. Try each selection preset → expected: `native` is indistinguishable from the system switcher's highlight; the others differ as described.
8. Open the preview, pick 100, press Show → expected: four seconds, the selection moving once a second, the ribbon drawn as the gesture would draw it.
9. Add five profiles → expected: adding a sixth is refused, with the reason visible.
10. Delete the active profile, then relaunch → expected: the built-in profile is active and the window opens on it.

## Risks and open questions

- **A profile that makes the ribbon unreadable.** The bounds are the answer; the built-in
  profile is always one click away if a user still manages it.
- **Native, exactly.** `native` is a claim about matching macOS. It is checked by eye in
  runbook step 7, against the system switcher on the same screen.
- **The preview at 100 entries** is the first place the layout is asked for a number the
  desktop rarely reaches; if it costs more than a frame to build, the sheet builds it once
  and reuses it.
