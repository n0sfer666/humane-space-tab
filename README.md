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
brew install --cask n0sfer666/tap/humane-space-tab
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

Requirements: macOS 15 Sequoia or later, Apple Silicon or Intel.

### Verify what you downloaded

```sh
shasum -a 256 HumaneSpaceTab-<version>.dmg          # compare with the release notes
gh attestation verify HumaneSpaceTab-<version>.dmg --repo n0sfer666/humane-space-tab
```

The attestation ties the artefact to the workflow run and the commit that built it.
Homebrew checks the same SHA-256 on its own.

## Documentation

The guide — the gestures, every setting, the menu bar, and what to do when something is
wrong — in the fifteen languages the app itself speaks:

[English](docs/guide.md) · [Русский](docs/guide.ru.md) · [Deutsch](docs/guide.de.md) ·
[Français](docs/guide.fr.md) · [Español](docs/guide.es.md) ·
[Português (Brasil)](docs/guide.pt-BR.md) · [Italiano](docs/guide.it.md) ·
[Nederlands](docs/guide.nl.md) · [Polski](docs/guide.pl.md) · [Türkçe](docs/guide.tr.md) ·
[Українська](docs/guide.uk.md) · [日本語](docs/guide.ja.md) · [한국어](docs/guide.ko.md) ·
[简体中文](docs/guide.zh-Hans.md) · [繁體中文](docs/guide.zh-Hant.md)

| | |
|---|---|
| Upgrading and uninstalling | [docs/homebrew.md](docs/homebrew.md) |
| What changed between releases | [CHANGELOG.md](CHANGELOG.md) |
| What the app can do with Accessibility | [S00 — threat model](docs/specs/S00-threat-model.md) |
| Reporting a vulnerability | [SECURITY.md](SECURITY.md) |
| The design, spec by spec | [docs/specs/](docs/specs/) |
| Building it, and what a change carries | [CONTRIBUTING.md](CONTRIBUTING.md) |

## Security

The app asks for **Accessibility** and nothing else — never Screen Recording, which is why
it shows no window previews. No network access, no AppleEvents, no plugins, no
subprocesses; a test fails the build on a forbidden API. The whole of it is in
[S00 — threat model](docs/specs/S00-threat-model.md).

## Licence

[GPL-3.0](LICENSE)
