<img src="docs/images/icon.png" width="120" align="right" alt="">

# humane-space-tab

A humane app switcher for macOS.

macOS switches between **all** open applications on `Cmd+Tab`, regardless of which
virtual desktop (Space) they live on. `humane-space-tab` restricts switching to the
applications of the **current Space** — and, further, aims to extend the same
Space-aware behaviour to the other grouping, hiding and revealing gestures of macOS.

> **Status: pre-release.** The switcher works. The roadmap still changes behaviour you
> can see, so releases stay below `1.0`.

[Русская версия](README.ru.md)

![The ribbon](docs/images/ribbon.png)

## Install

```sh
brew install --cask n0sfer/tap/humane-space-tab
```

Without Homebrew: download `HumaneSpaceTab-<version>.dmg` from
[Releases](../../releases), open it and drag the app onto the Applications shortcut. The
zip beside it holds the same bundle for anyone who prefers one.

Either way macOS asks for two things, once:

- **Allow the first launch.** It is refused, because the build carries no Apple Developer
  ID. Open **System Settings → Privacy & Security**, scroll to the bottom, press **Open
  Anyway**, and launch the app again. Do not strip the quarantine attribute by hand — that
  habit disarms the check that protects you from everything else you download.
- **Grant Accessibility.** The app asks as it launches, and its menu bar icon shows a
  warning until the grant is there — **Grant Accessibility…** in that menu asks again.
  Either way the switcher starts working within a couple of seconds, without a relaunch.
  macOS ties the grant to the code signature, so it has to be given again after every
  update.

Upgrading and uninstalling: [docs/homebrew.md](docs/homebrew.md). A missing menu bar icon,
key presses macOS withholds, a grant that belongs to the previous build —
[when something is wrong](docs/guide.md#when-something-is-wrong) in the guide. What
changed between releases is in [CHANGELOG.md](CHANGELOG.md).

### Verify what you downloaded

```sh
shasum -a 256 HumaneSpaceTab-<version>.dmg          # compare with the release notes
gh attestation verify HumaneSpaceTab-<version>.dmg --repo n0sfer/humane-space-tab
```

The attestation ties the artefact to the workflow run and the commit that built it.
Homebrew checks the same SHA-256 on its own.

## Using it

Hold **⌘** and tap **Tab**. A quick tap switches to the previous application without
showing anything; keep **⌘** down and the ribbon appears with the applications of the
current Space — **Tab** steps forward, **⇧Tab** back, **Escape** cancels, releasing **⌘**
switches. `` ⌘` `` does the same for the windows of the application in front. The pointer
works on the ribbon too: move it to select, click to switch, scroll to step.

Both shortcuts, the reveal delay, the screen the ribbon opens on, window switching and
launch at login are in **Settings…**, in the menu bar icon's menu.

The full guide — every setting, the menu bar, and what to do when something is wrong — is
[docs/guide.md](docs/guide.md) ([по-русски](docs/guide.ru.md)).

## Requirements

- macOS 15 Sequoia or later
- Apple Silicon or Intel

## Security

`humane-space-tab` needs the macOS **Accessibility** permission: intercepting
`Cmd+Tab` and raising other applications' windows is impossible without it. That
permission is broad, so the threat model matters more than usual here. The
project's standing commitments:

- no network access of any kind;
- no AppleEvents / scripting bridge into other applications;
- no plugin system and no user-supplied code or scripts;
- keystrokes are inspected only to match the configured shortcut, never stored,
  logged or forwarded — the sole exception is the combination you deliberately
  record as your own shortcut;
- window titles are read only while the optional window switching is turned on, and
  only to be drawn on the ribbon: never logged, never written to disk, never sent
  anywhere;
- the pointer is seen only over the ribbon's own panel, and only while the ribbon is
  on screen: no global mouse monitoring, nothing recorded anywhere;
- hardened runtime, no entitlements beyond what is strictly required;
- everything auditable — the full source is here, under GPL-3.0.

The app asks for **Accessibility and nothing else**. It never requests Screen
Recording, which means it deliberately does not show window previews — that
feature is the reason comparable switchers hold a permission that can read the
contents of every window on your screen. It never asks for Input Monitoring
either; where a stale entry in that list makes macOS withhold key presses, the
menu bar says so and offers the pane that can undo it.

Builds are **ad-hoc signed** — there is no Apple Developer ID. That is what the two
one-time steps above are about, and why Accessibility has to be granted again after
every update.

The full threat model is [S00](docs/specs/S00-threat-model.md); how to report a
vulnerability is [SECURITY.md](SECURITY.md).

## Goals

- **Native first** — Swift 6 + AppKit, no cross-platform runtime.
- **Small footprint** — minimal bundle size and memory usage.
- **UI/UX** — the switcher should feel like part of the system, not an add-on.
- **Launch at login** — opt-in, via the system-supported mechanism.
- **Security** — the app requires Accessibility to work; the design deliberately
  minimises what it can do with it. See [Security](#security).

## Development

Ports and adapters, one direction only: `SwitcherCore` (pure logic) → `SystemPorts` →
`SystemAdapters` and `SwitcherUI` → `App`. Swift 6 and AppKit, Swift Package Manager for
the modules and XcodeGen for the bundle, Swift Testing throughout, `dev` for work and
`main` for releases, and a mini-spec in `docs/specs/` before a feature is built.

```sh
brew install xcodegen swiftlint     # Xcode 26 is the other requirement
swift test
scripts/install.sh 0.1.0            # packages, installs into /Applications, relaunches
```

What a change is expected to carry, and the rest of the commands, are in
[CONTRIBUTING.md](CONTRIBUTING.md); packaging and what a `v*` tag does are in
[S11](docs/specs/S11-packaging-release.md).

## Licence

[GPL-3.0](LICENSE)
