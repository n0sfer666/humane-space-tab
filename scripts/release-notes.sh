#!/usr/bin/env bash
set -euo pipefail

version="${1:-}"
repo="${2:-}"

if [[ -z "$version" || -z "$repo" ]]; then
    echo "usage: scripts/release-notes.sh <version> <owner/repo>" >&2
    exit 64
fi

if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "error: '$version' is not MAJOR.MINOR.PATCH" >&2
    exit 64
fi

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
sidecar="$root/dist/HumaneSpaceTab-$version.zip.sha256"

if [[ ! -f "$sidecar" ]]; then
    echo "error: $sidecar is missing — run scripts/package.sh first" >&2
    exit 1
fi

read -r sum _ <"$sidecar"

cat <<NOTES
\`Cmd+Tab\` between the applications of the current Space, and nothing else.

## Install

1. Download \`HumaneSpaceTab-$version.zip\` and unpack it.
2. Move **Humane Space Tab.app** to \`/Applications\`.
3. Launch it. macOS will refuse the first time: open **System Settings → Privacy &
   Security**, scroll to the bottom and press **Open Anyway**, then launch it again.
4. The menu bar icon shows a warning until Accessibility is granted. Use
   **Grant Accessibility…** from its menu — the switcher starts working within a couple
   of seconds, without a relaunch.

## Verify the download

\`\`\`
shasum -a 256 HumaneSpaceTab-$version.zip
# $sum

gh attestation verify HumaneSpaceTab-$version.zip --repo $repo
\`\`\`

The attestation ties this artefact to the workflow run and the commit that built it.

## What ad-hoc signing costs you

This app is signed ad-hoc: there is no Apple Developer Program behind it, and no
notarisation. Two consequences, stated rather than hidden:

- **Gatekeeper refuses the first launch.** That is the **Open Anyway** step above. Do not
  strip the quarantine attribute by hand — that habit disarms the check that protects you
  from everything else you download.
- **Accessibility has to be granted again after every update.** macOS ties the grant to
  the code signature, and each build is a new identity. The menu bar icon says so instead
  of leaving you with a switcher that silently does nothing.

## Scope

Pre-release. The switcher works; the roadmap past this point still changes behaviour you
can see, so the version stays below \`1.0\`.
NOTES
