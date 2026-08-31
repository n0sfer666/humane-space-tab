# Changelog

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the
project follows [semantic versioning](https://semver.org/spec/v2.0.0.html). Until `1.0`
the switcher's visible behaviour is still being decided, so a minor version may change it.

## [Unreleased]

## [0.1.0] — unreleased

The first packaged build: `Cmd+Tab` switches between the applications of the current
Space, and nothing else.

### Added

- **Space-aware switching.** `Cmd+Tab` lists the applications of the current Space in
  most-recently-used order and raises the one you release on; `Shift` reverses, `Escape`
  cancels. A tap shorter than the reveal delay switches without showing anything.
- **The ribbon.** A glass panel with one icon per entry — the selection bigger and
  brighter, its neighbours dimmed, its name underneath. From five applications on it is a
  closed carousel: the selection keeps its place, the icons turn under it, and the panel
  stops growing at ten slots.
- **The pointer.** Moving the mouse over the ribbon selects, a click switches at once, a
  scroll steps the selection.
- **Windows of one application.** ``Cmd+` `` cycles the windows of the front application
  on this Space, in stacking order, by title. Turned into the main list by the
  *Switch between windows, not applications* preference.
- **Settings.** Both shortcuts (recorded by typing them, with the refusals explained), the
  screen the ribbon opens on, the reveal delay, launch at login, window switching, and the
  private Space layer — all applied live, without a relaunch.
- **Permission handling.** The app asks for Accessibility on launch, says in the menu bar
  when the grant is missing, and starts working within seconds of it being given. A tap
  that macOS has silenced through a stale Input Monitoring entry is reported as its own
  state, with the pane that undoes it one click away.
- **A drawn bundle icon**, every size rendered from one script.
- **Packaging and release.** One script builds, checks and packs a universal, hardened,
  ad-hoc-signed bundle; the release workflow only calls it and attaches provenance.

### Security

- No network code, no AppleEvents, no plugins, no subprocesses — enforced by a test that
  scans the shipped sources for the forbidden symbols.
- The app asks for Accessibility and nothing else: never Screen Recording, never Input
  Monitoring. Window titles are read only while window switching is on, and only to be
  drawn.

### Known issues

- **Open at login is refused on some copies.** `SMAppService` reports the bundle as
  unregistrable and the checkbox stays disabled with that message. Nothing else is
  affected.

[Unreleased]: https://github.com/n0sfer/humane-space-tab/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/n0sfer/humane-space-tab/releases/tag/v0.1.0
