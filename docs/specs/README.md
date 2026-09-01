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
| S03 | [Space attribution](S03-space-attribution.md) | Current Space and window membership; public base, private layer, degradation | agreed |
| S04 | [Hotkey engine](S04-hotkey-engine.md) | `CGEventTap`, `Cmd+Tab` interception, arm/re-arm, modes, configurability | agreed |
| S05 | [Switcher state machine](S05-switcher-state-machine.md) | Cmd-hold cycle, Tab/Shift-Tab, MRU order, cancellation | agreed |
| S06 | [Activation](S06-activation.md) | Raising the selected application or window, focus correctness | agreed |
| S07 | [Overlay UI](S07-overlay-ui.md) | `NSPanel`, rendering, icons, animation, multi-display | agreed |
| S08 | [Preferences & persistence](S08-preferences.md) | Settings window, storage, live application | agreed |
| S09 | [Launch at login](S09-launch-at-login.md) | `SMAppService`, login-item state in the settings window | agreed |
| S10 | [Permission UX](S10-permission-ux.md) | Requesting Accessibility, explaining it, recovering after revocation | agreed |
| S11 | [Packaging & release](S11-packaging-release.md) | Packaging script, release workflow, provenance, what ad-hoc signing costs | agreed |
| S12 | [Windows of the front application](S12-front-application-windows.md) | A second shortcut cycling the front application's windows on this Space | agreed |
| S13 | [Shortcut editor](S13-shortcut-editor.md) | Recording and validating a replacement for `Cmd+Tab` | agreed |
| S14 | [Overlay mouse interaction](S14-overlay-mouse.md) | Hover, click and scroll selection, and the panel changes they need | agreed |
| S15 | [The deaf tap](S15-deaf-tap.md) | Noticing a tap that receives no key events, and naming the cure | agreed |
| S16 | [Windows of one application](S16-windows-of-one-application.md) | Cycling windows instead of applications, behind S08's preference | agreed |
| S17 | [Appearance & profiles](S17-appearance-profiles.md) | The ribbon's looks, bounded and named: metrics, background, carousel, presets, profiles | agreed |
| S18 | [The empty Space](S18-empty-space.md) | What the ribbon says on a Space with nothing open, instead of macOS's own switcher | agreed |
| S19 | [Languages](S19-languages.md) | The interface in the language the system is set to, translated from a glossary rather than word by word | agreed |
| S20+ | Beyond the ribbon | Mission Control, App Exposé, hide/minimise — one spec per gesture | planned |

S00–S06 are close to pure logic and are covered by automated tests. S07 onwards
needs verification on a real machine; each such spec carries a manual runbook.

The map is a living document — specs may be added, split or reordered as the
design develops.
