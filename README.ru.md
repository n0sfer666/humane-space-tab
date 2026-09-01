<img src="docs/images/icon.png" width="120" align="right" alt="">

# humane-space-tab

Человечный переключатель приложений для macOS.

По `Cmd+Tab` macOS переключается между **всеми** открытыми приложениями, независимо
от того, на каком виртуальном столе (Space) они находятся. `humane-space-tab`
ограничивает переключение приложениями **текущего стола** — и, дальше, распространяет
то же поведение на остальные жесты и функции macOS, связанные с групповым
отображением, сворачиванием и разворачиванием приложений.

> **Статус: пре-релиз.** Переключатель работает. Роадмап ещё меняет заметное
> поведение, поэтому версии остаются ниже `1.0`.

[English version](README.md)

![Лента](docs/images/ribbon.png)

## Установка

```sh
brew install --cask n0sfer/tap/humane-space-tab
```

Без Homebrew: скачайте `HumaneSpaceTab-<версия>.dmg` со страницы
[Releases](../../releases), откройте и перетащите приложение на ярлык Applications. Рядом
лежит zip с тем же бандлом — для тех, кому так привычнее.

В обоих случаях macOS попросит две вещи, по одному разу:

- **Разрешить первый запуск.** Он будет отклонён, потому что у сборки нет Apple Developer
  ID. Откройте **System Settings → Privacy & Security**, пролистайте вниз, нажмите **Open
  Anyway** и запустите приложение снова. Не снимайте атрибут карантина руками — эта
  привычка отключает проверку, которая защищает вас от всего остального скачанного.
- **Выдать Accessibility.** Приложение просит его при запуске, а его иконка в меню-баре
  показывает предупреждение, пока разрешения нет; **Grant Accessibility…** в её меню
  спрашивает снова. В обоих случаях переключатель заработает за пару секунд, без
  перезапуска. macOS привязывает разрешение к подписи кода, поэтому после каждого
  обновления его придётся выдать заново.

Требования: macOS 15 Sequoia или новее, Apple Silicon или Intel.

### Проверка скачанного

```sh
shasum -a 256 HumaneSpaceTab-<версия>.dmg          # сверьте с описанием релиза
gh attestation verify HumaneSpaceTab-<версия>.dmg --repo n0sfer/humane-space-tab
```

Аттестация связывает артефакт с запуском workflow и коммитом, который его собрал.
Homebrew сверяет тот же SHA-256 сам.

## Документация

Гайд — жесты, все настройки, меню-бар и что делать, если что-то не так — на тех же
пятнадцати языках, на которых говорит само приложение:

[English](docs/guide.md) · [Русский](docs/guide.ru.md) · [Deutsch](docs/guide.de.md) ·
[Français](docs/guide.fr.md) · [Español](docs/guide.es.md) ·
[Português (Brasil)](docs/guide.pt-BR.md) · [Italiano](docs/guide.it.md) ·
[Nederlands](docs/guide.nl.md) · [Polski](docs/guide.pl.md) · [Türkçe](docs/guide.tr.md) ·
[Українська](docs/guide.uk.md) · [日本語](docs/guide.ja.md) · [한국어](docs/guide.ko.md) ·
[简体中文](docs/guide.zh-Hans.md) · [繁體中文](docs/guide.zh-Hant.md)

| | |
|---|---|
| Обновление и удаление | [docs/homebrew.md](docs/homebrew.md) |
| Что менялось от релиза к релизу | [CHANGELOG.md](CHANGELOG.md) |
| Что приложение может делать с Accessibility | [S00 — модель угроз](docs/specs/S00-threat-model.md) |
| Как сообщить об уязвимости | [SECURITY.md](SECURITY.md) |
| Устройство, спека за спекой | [docs/specs/](docs/specs/) |
| Как собрать и что должно нести изменение | [CONTRIBUTING.md](CONTRIBUTING.md) |

## Безопасность

Приложение просит **Accessibility** и больше ничего — Screen Recording не запрашивается
никогда, поэтому превью окон здесь и нет. Ни сети, ни AppleEvents, ни плагинов, ни
подпроцессов; запрещённый API роняет сборку на тесте. Целиком — в
[S00 — модель угроз](docs/specs/S00-threat-model.md).

## Лицензия

[GPL-3.0](LICENSE)
