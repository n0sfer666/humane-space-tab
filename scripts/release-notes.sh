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
image_sidecar="$root/dist/HumaneSpaceTab-$version.dmg.sha256"

for file in "$sidecar" "$image_sidecar"; do
    if [[ ! -f "$file" ]]; then
        echo "error: $file is missing — run scripts/package.sh first" >&2
        exit 1
    fi
done

read -r sum _ <"$sidecar"
read -r image_sum _ <"$image_sidecar"

cat <<NOTES
\`Cmd+Tab\` between the applications of the current Space, and nothing else.

Hold \`Cmd\`, tap \`Tab\`: a quick tap switches to the previous application, holding it
opens a ribbon of the applications on this desk — \`Shift\` reverses, \`Escape\` cancels, the
mouse selects and clicks. \`\`Cmd+\` \`\` does the same for the windows of the front
application. Both shortcuts, the reveal delay and the rest are in **Settings…**, in the
menu bar icon's menu.

- [What is in this release](https://github.com/$repo/blob/v$version/CHANGELOG.md)
- [Guide](https://github.com/$repo/blob/v$version/docs/guide.md) ·
  [Гайд по-русски](https://github.com/$repo/blob/v$version/docs/guide.ru.md)

## Install

\`\`\`
brew install --cask n0sfer/tap/humane-space-tab
\`\`\`

Or by hand: download \`HumaneSpaceTab-$version.dmg\`, open it and drag the app onto the
Applications shortcut. (\`HumaneSpaceTab-$version.zip\` holds the same bundle, unpacked
by Finder.)

Either way, two steps macOS keeps for itself:

1. **The first launch is refused.** Open **System Settings → Privacy & Security**, scroll
   to the bottom and press **Open Anyway**, then launch the app again.
2. **Accessibility.** The menu bar icon shows a warning until the grant is there — use
   **Grant Accessibility…** from its menu. The switcher starts working within a couple of
   seconds, without a relaunch.

## Verify the download

\`\`\`
shasum -a 256 HumaneSpaceTab-$version.dmg
# $image_sum

shasum -a 256 HumaneSpaceTab-$version.zip
# $sum

gh attestation verify HumaneSpaceTab-$version.dmg --repo $repo
\`\`\`

The attestation covers both artefacts, and ties each to the workflow run and the commit
that built it.

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
