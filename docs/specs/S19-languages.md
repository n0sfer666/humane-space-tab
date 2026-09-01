# S19 — Languages

**Status:** agreed · **Depends on:** [S01](S01-architecture.md), [S08](S08-preferences.md), [S17](S17-appearance-profiles.md) · **ADRs:** —

## Goal

The interface speaks the language the system is set to, in fifteen languages, translated
from a glossary rather than word by word. A person who has never read English should be
able to set the shortcut, understand what the private Space layer costs them, and know why
the ribbon says nothing is open.

## Non-goals

- No translation of what the system already names: application names and window titles come
  from macOS and are shown as they arrive.
- No translation of the inventory dump behind **Copy Inventory**. It is a bug report, read
  by whoever answers the issue, and it stays English on purpose.
- No right-to-left languages in this spec. Arabic and Hebrew need the ribbon and the forms
  mirrored and checked by eye; that is its own piece of work.
- No translated documentation. The README already has a Russian twin; the rest is English.

## Design

### The languages

`en` (the source), `ru`, `de`, `fr`, `es`, `pt-BR`, `it`, `nl`, `pl`, `tr`, `uk`, `ja`,
`ko`, `zh-Hans`, `zh-Hant`.

### Where the words live

Every user-facing string moves out of the code into `Sources/SwitcherUI/Resources/<lang>.lproj/Localizable.strings`,
carried by `SwitcherUI`'s own resource bundle. `UIText` is a `CaseIterable` enum of keys —
the whole vocabulary of the interface in one place — and `Localised.text(_:)` is the only
way a view gets a word.

Because the keys are an enum and not free-form strings, the test suite can walk every key
in every language: a missing key, an empty value, or a placeholder that changed shape
(`%@`, `%lld`) fails the build rather than reaching a user as a blank label.

### The architecture keeps its shape

`SwitcherCore` imports nothing and cannot look a word up, so the display text it carries
today — `OverlayScreenChoice.label`, `LoginItemStatus.message`, `PermissionState.detail` —
moves to `SwitcherUI`, which maps a core value to a `UIText`. The core keeps the states;
the interface keeps the words. `SpaceMembershipLayer.label` stays where it is: it is part
of the English inventory dump, not of the interface.

### Which language, and how it is chosen

`InterfaceLanguage` is a value in `SwitcherCore`: `.system`, or one of the fifteen. The
default is `.system`, and then the bundle answers in whatever macOS ranks first among the
languages the app has — the behaviour every native application has.

Beyond that, **General** gains a **Language** popup whose first item is **System**. It is
stored with the other preferences (S08) under `InterfaceLanguage`, and choosing one rebuilds
the settings window so the change is visible without a relaunch — AppKit builds its labels
once, and a window that keeps its old words is worse than a window that blinks.

`CFBundleLocalizations` in `Info.plist` lists the fifteen, so the app also appears in System
Settings › General › Language & Region › Applications, where macOS offers the same choice
per application.

### Translating, not word-swapping

`docs/glossary.md` fixes the terms before any translation is written: **Space**, **ribbon**,
**switcher**, **carousel**, **profile**, **slot**, **frame**, **reveal delay**, **login
item**, and how each is said in each language. Two rules decide the wording:

1. **The system's own word wins.** What macOS calls a Space in Russian is what we call it.
   A translation that invents a term teaches the user a word they will not find in System
   Settings.
2. **Meaning over letters.** "Copy Inventory" is a command to copy a diagnostic report, not
   an instruction about groceries; where the English is idiomatic the translation says what
   the button does in that language's idiom.

## Definition of Done

- [x] Every user-facing string in the app comes from `Localised`, and no view holds a literal.
- [x] All fifteen languages carry every key, with no empty values and matching placeholders — checked by tests.
- [ ] With the system set to a supported language, the settings window, the menu bar and the ribbon's placeholder are in it.
- [ ] With the system set to an unsupported language, everything is English and nothing is blank.
- [ ] **General** has a Language popup starting at System, and choosing one changes the window without a relaunch.
- [x] `SwitcherCore` holds no user-facing display strings except the English inventory dump.
- [x] `docs/glossary.md` lists the shared terms and their translation in every language.

## Test cases

| # | Case | Expected |
|---|------|----------|
| 1 | Every `UIText` key, in every `.lproj` | present, non-empty |
| 2 | A key whose English carries `%@` or `%lld` | every translation carries the same placeholders, in some order |
| 3 | `Localised` with an unsupported language | the English value, never the raw key |
| 4 | `InterfaceLanguage(stored:)` over nonsense | `.system` |
| 5 | The popup's list | System first, then the fifteen in their own names ("Deutsch", not "German") |
| 6 | A language chosen, then the window reopened | the choice survives, read back from preferences |

## Manual runbook

1. Set macOS to Russian, launch → expected: the menu bar, the settings window and the empty-Space
   ribbon are Russian, and no label is cut off by its control.
2. Settings → General → Language → Deutsch → expected: the window redraws in German at once.
3. Set it back to System with macOS in a language we do not have (Danish) → expected: English.
4. Read the German and Japanese settings window against the glossary → expected: the terms are the
   ones the glossary fixes, and the columns still line up.
5. Copy Inventory in any language → expected: the report is English.

## Risks and open questions

- **A translation that fits the sentence but not the control.** German and Russian run long;
  the forms size themselves from their content, so a long label widens the window rather
  than clipping — checked in runbook step 4 for the two longest languages.
- **A term the system names differently across versions.** The glossary records the macOS
  wording we matched, so a later change is a documented edit rather than a rediscovery.
