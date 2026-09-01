# Security

This app holds the macOS **Accessibility** permission. That permission is broad — broad
enough that a flaw here is worth reporting carefully rather than publicly.

## Reporting a vulnerability

Use **[Report a vulnerability](../../security/advisories/new)** on the Security tab. It
opens a private advisory that only the maintainers can see. Please do not open a public
issue for anything that could be used against someone before it is fixed.

Say what you can:

- what an attacker gets out of it, and what they need to have already;
- the version (menu bar → **Settings…** shows it in the window title bar, or
  `defaults read /Applications/Humane\ Space\ Tab.app/Contents/Info CFBundleShortVersionString`);
- macOS version, and whether the app had Accessibility at the time;
- steps, a crash log, or a patch — whatever you have.

Expect a first answer within a week. There is no bounty: this is one person's project
under GPL-3.0.

## What counts

The project's standing commitments are the ones worth breaking:

- no network access of any kind;
- no AppleEvents / scripting bridge into other applications;
- no plugin system, no user-supplied code or scripts, no subprocesses;
- keystrokes inspected only to match the configured shortcut, never stored, logged or
  forwarded — the one exception is the combination deliberately recorded as a shortcut;
- window titles read only while window switching is on and only to be drawn: never
  logged, never written to disk, never sent anywhere;
- the pointer seen only over the ribbon's own panel, and only while it is on screen;
- hardened runtime, no entitlements beyond what is strictly required;
- Accessibility and nothing else — never Screen Recording, never Input Monitoring.

Anything that makes one of those false is a vulnerability, whether or not it is
exploitable today. A test guards the first three by scanning the shipped sources for the
forbidden symbols; if you find a way around that test, that is a finding too.

The full threat model, including what is deliberately out of scope, is
[docs/specs/S00-threat-model.md](docs/specs/S00-threat-model.md).

## What does not count

- **Gatekeeper refusing the first launch.** Builds are ad-hoc signed; there is no Apple
  Developer ID. It is documented, not a defect.
- **Accessibility having to be granted again after an update.** macOS ties the grant to
  the code signature, and every build carries a new one.
- **Anything that requires an attacker who already runs code as you.** At that point the
  Accessibility grant is theirs regardless of this app.

## Supported versions

The latest release only. Until `1.0` there are no maintained branches behind it.
