# Mini-specs

Every feature is designed here before it is built. One mini-spec is one coherent
responsibility with its own Definition of Done; it is written and agreed first,
then implemented test-first.

Foundational decisions that cut across specs live in [`docs/adr/`](../adr/).

New specs start from [`TEMPLATE.md`](TEMPLATE.md).

## Status

| № | Spec | Scope | Status |
|---|------|-------|--------|
| S00 | [Threat model](S00-threat-model.md) | What the app can and cannot do with Accessibility; boundaries, entitlements | agreed |
| S01 | [Architecture & modules](S01-architecture.md) | SPM module boundaries, system APIs isolated behind protocols for testability | agreed |
| S02 | [App & window inventory](S02-inventory.md) | Domain model of applications and windows, data source, public API | agreed |
| S03 | Space attribution | Current Space and window membership; public base, private layer, degradation | planned |
| S04 | Hotkey engine | `CGEventTap`, `Cmd+Tab` interception, arm/re-arm, modes, configurability | planned |
| S05 | Switcher state machine | Cmd-hold cycle, Tab/Shift-Tab, MRU order, cancellation | planned |
| S06 | Activation | Raising the selected application or window, focus correctness | planned |
| S07 | Overlay UI | `NSPanel`, rendering, icons, animation, multi-display | planned |
| S08 | Preferences & persistence | Settings, storage, shortcut editor | planned |
| S09 | Launch at login | `SMAppService` | planned |
| S10 | Permission UX | Requesting Accessibility, explaining it, recovering after revocation | planned |
| S11 | Packaging & release | Bundle, signing, notarisation, DMG/Homebrew, release flow | planned |
| S12+ | Beyond `Cmd+Tab` | Mission Control, App Exposé, hide/minimise — one spec per gesture | planned |

S00–S06 are close to pure logic and are covered by automated tests. S07 onwards
needs verification on a real machine; each such spec carries a manual runbook.

The map is a living document — specs may be added, split or reordered as the
design develops.
