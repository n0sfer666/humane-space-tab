# S11 — Packaging & release

**Status:** agreed · **Depends on:** S00, S09, S10 · **ADRs:** 0001

## Goal

Turn a green `dev` into something a stranger can install and verify. One command on a
tag produces a signed-as-far-as-we-sign bundle, a zip, a checksum and a provenance
attestation, and a GitHub Release that tells the user exactly what they are getting and
what ad-hoc signing costs them.

## Non-goals

- **Notarisation and Developer ID.** S00 decided against the Apple Developer Program.
  Nothing here quietly reopens that: no team id, no notary submission.
- **The Mac App Store.** Closed off by ADR 0001 — the app needs Accessibility and an
  event tap.
- **In-app updates.** Sparkle is a third-party framework, and S00 forbids linking
  anything outside the system frameworks. Updating means downloading the next release.
- **A Homebrew tap.** Deliberately deferred: a tap that points at a release pipeline
  nobody has run yet is two moving parts instead of one. It gets its own step once the
  release flow has produced a real artefact.
- **A DMG.** The zip is what Homebrew and a double-click both handle; a disk image is a
  second artefact that can rot independently of the first.

## Design

### One packaging script, three callers

The whole of packaging lives in `scripts/package.sh`; the release workflow, the CI
bundle job and a developer's laptop all call the same script. This is not tidiness: a
workflow that exists only inside GitHub can be verified only by pushing tags at
production, so the interesting part is deliberately kept where it can be run — and
broken — on a laptop. CI calling it too means the release path is exercised on every
push rather than first on a tag, and the structural assertions exist in exactly one
place.

The release notes are the same story: `scripts/release-notes.sh` renders them from the
version and the artefact's own checksum, so the text a user reads can be reviewed on a
laptop instead of living inside a YAML string.

The script takes a version, and it:

1. generates the Xcode project with XcodeGen, so the checked-in `project.yml` is the
   single source of build settings;
2. builds Release with `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` overridden from
   the version it was given, so the tag names the build rather than a number someone
   forgot to bump in `project.yml`;
3. asserts the five structural properties a release has to have — both architectures
   present, no entitlements, hardened runtime on, only system frameworks linked, and a
   valid signature;
4. packs the bundle with `ditto -c -k --keepParent`, which preserves the extended
   attributes and the code signature that a plain `zip` quietly drops;
5. prints the SHA-256 of the zip and leaves both in `dist/`.

Any failed assertion fails the script. A release that cannot prove those five properties
is not a release.

Every assertion is a positive control: the tool has to succeed *and* its output has to
say the right thing. `codesign -d` on a missing bundle prints nothing and a check shaped
as "the output does not contain the bad word" would pass — a security check that goes
green on its own failure is worse than no check.

### Universal, and checked per slice

macOS 15 still runs on Intel, so Release is built for `arm64` and `x86_64` and the script
refuses a bundle that is missing either slice. Architecture is not left to the build
machine: a runner that changed CPU would otherwise silently narrow the release.

The slices have to be checked one at a time. `codesign -d` reports the host architecture
unless it is given `--arch`, and `otool -L` prints the host slice unless it is given
`-arch all`, so a single check on a universal binary inspects half the artefact. The
linkage check walks every Mach-O in the bundle rather than the main executable alone —
today there is only one, and the check is there for the day there is not.

### The version comes from the tag

`v0.1.0` → `0.1.0`. The script refuses a version that is not `MAJOR.MINOR.PATCH`, so a
mistyped tag cannot produce a bundle whose `CFBundleShortVersionString` is nonsense.
`CURRENT_PROJECT_VERSION` is the run number in CI and `0` locally: it has to increase
between builds of the same version, and nothing else depends on it.

### What the release publishes

- `HumaneSpaceTab-<version>.zip` — the bundle, as built.
- Its SHA-256, in the release notes, so the download can be checked before it is opened.
- A build provenance attestation (`actions/attest-build-provenance`), which ties the
  artefact to the workflow run and the commit that produced it. `gh attestation verify`
  is then a one-line check a user can run themselves.

The release is created as a **pre-release**. The app works, but the roadmap past S11
still changes behaviour the user can see, and a `1.0`-shaped promise would be a lie.

### Ad-hoc signing, said out loud

The signature is ad-hoc (`CODE_SIGN_IDENTITY = "-"`), and the consequences belong in the
release notes rather than in a FAQ nobody reads:

- **Accessibility must be granted again after every update.** The grant is tied to the
  code signature; a new build is a new identity. S10 already makes that state visible
  instead of leaving a switcher that silently does nothing.
- **Gatekeeper will refuse the first launch.** A downloaded zip carries the quarantine
  attribute, so macOS 15 sends the user to System Settings → Privacy & Security →
  Open Anyway. The release notes say so, with the exact click path.
- **`xattr -d` is not the advice.** Telling users to strip quarantine trains them to
  disarm the one check that protects them from everyone else. The Open Anyway path is
  one extra click and leaves the check in place.

### Manual dispatch

The workflow also runs on `workflow_dispatch` with a version input, and skips creating a
release when it was dispatched rather than tagged. That is how the pipeline gets
exercised before the first tag exists: same script, same assertions, artefact uploaded
to the run instead of to a release. The provenance attestation is issued for those runs
too — deliberately, so the step is exercised rather than first tried on a tag. An
attestation is a statement about where an artefact came from, not a claim that it was
published, and a dispatch artefact is reachable only by someone who can already read the
run.

### The write token is scoped to the one step that needs it

Packaging and publishing are separate jobs. The macOS job builds, asserts, attests and
uploads the artefact with `contents: read`; the token that can write to the repository
lives only in the small Linux job that creates the release, which runs no build tooling
of its own. `persist-credentials: false` keeps the checkout from leaving a usable token
in `.git/config` while `brew` and `xcodebuild` run. The release job re-checks the
artefact's SHA-256 after the round trip, so what is published is provably the bytes that
were attested.

## Definition of Done

- [ ] `scripts/package.sh 0.1.0` produces `dist/HumaneSpaceTab-0.1.0.zip` on a clean checkout.
- [ ] The script fails, loudly, if the bundle carries entitlements, lacks hardened runtime, links a non-system library, or fails signature verification.
- [ ] The version inside the built bundle matches the version passed in.
- [ ] The zip unpacks to a bundle that launches and whose signature is still valid.
- [ ] The release workflow runs on a `v*` tag and on manual dispatch, and only the tag creates a release.
- [ ] The release carries the zip, its SHA-256 in the notes, and a provenance attestation.
- [ ] The release notes state the Accessibility re-grant and the Gatekeeper path, and never suggest stripping quarantine.
- [ ] `README.md` and `README.ru.md` document install, first launch, and how to verify the download.
- [ ] The structural assertions exist once, in the script, and CI runs them by calling it.
- [ ] The bundle is universal, and the script fails if either slice is missing.
- [ ] Every assertion fails when its tool fails, not only when its output looks wrong.
- [ ] The token that can write to the repository is not present while the build runs.

## Test cases

| # | Case | Expected |
|---|------|----------|
| 1 | `package.sh` with no version | usage error, nothing built |
| 2 | `package.sh 1.2` | rejected as not `MAJOR.MINOR.PATCH` |
| 3 | `package.sh 0.1.0` | zip in `dist/`, SHA-256 printed |
| 4 | built bundle | `CFBundleShortVersionString` equals the version passed in |
| 5 | built bundle | no entitlements, hardened runtime on, only system frameworks, per slice |
| 5a | built bundle | `arm64` and `x86_64` slices both present |
| 5b | a slice re-signed without the runtime | rejected |
| 5c | a check pointed at a missing bundle | fails, rather than passing on empty output |
| 6 | packed zip | unpacks to a bundle whose signature verifies |
| 7 | workflow, tag push | release created, marked pre-release, zip and `.sha256` attached |
| 7a | workflow, tag push, release already exists | notes and assets replaced, no failure |
| 8 | workflow, manual dispatch | artefact uploaded to the run, no release created |
| 9 | `release-notes.sh` with no arguments | usage error, exit 64 |
| 10 | `release-notes.sh` before packaging | refuses, names the missing zip |

## Manual runbook

1. `scripts/package.sh 0.1.0` on a clean checkout → expected: `dist/HumaneSpaceTab-0.1.0.zip`
   and a printed SHA-256.
2. `ditto -x -k dist/HumaneSpaceTab-0.1.0.zip /tmp/check && codesign --verify --strict --deep '/tmp/check/Humane Space Tab.app'`
   → expected: no output, exit 0. `ditto`, not `unzip`: unpacking has to restore the
   extended attributes that packing preserved.
3. Move the unpacked app to `/Applications`, launch it, grant Accessibility → expected:
   the menu bar icon loses its warning and `Cmd+Tab` shows our ribbon.
4. Rebuild and replace the app, launch again → expected: the warning is back and the
   grant has to be given again — the ad-hoc signing consequence, observed rather than
   assumed.
5. `lipo -archs` on the unpacked binary → expected: `x86_64 arm64`.
6. After the first tag: `gh attestation verify dist/HumaneSpaceTab-0.1.0.zip --repo n0sfer666/humane-space-tab`
   → expected: verification succeeds.

## Risks and open questions

- **The workflow is verified indirectly.** Everything interesting is in the script and is
  run locally; the workflow itself is only proven by dispatching it once for real. Until
  that dispatch happens, the release job is untested code.
- **Ad-hoc signing makes updates hostile.** Every update costs the user a trip to System
  Settings. That is the price S00 accepted; if it turns out to be the thing that stops
  people using the app, the Developer ID decision is the one to revisit, not this spec.
- **Shell pipelines lie under `pipefail`.** `codesign -dv | grep -q` fails intermittently:
  `grep -q` exits on the first match, `codesign` takes SIGPIPE, and `pipefail` reports the
  whole pipeline as failed — a check that passes or fails by a race. No assertion in the
  script pipes into a reader that can exit early: each captures its command's output into
  a variable and matches against that.
- **`CURRENT_PROJECT_VERSION` is the CI run number.** Two releases of the same version
  from different runs would differ in build number only. Tags are immutable in practice,
  so this is a theoretical wart rather than a real one.
