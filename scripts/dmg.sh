#!/usr/bin/env bash
set -euo pipefail

app="${1:-}"
dmg="${2:-}"

if [[ -z "$app" || -z "$dmg" ]]; then
    echo "usage: scripts/dmg.sh <app bundle> <output.dmg>" >&2
    exit 64
fi

if [[ ! -d "$app" ]]; then
    echo "error: $app is not a bundle" >&2
    exit 1
fi

volume="Humane Space Tab"
staging="$(mktemp -d)"
mount=""

cleanup() {
    [[ -n "$mount" ]] && hdiutil detach "$mount" -quiet 2>/dev/null || true
    rm -rf "$staging"
}
trap cleanup EXIT

ditto "$app" "$staging/$(basename "$app")"
ln -s /Applications "$staging/Applications"

rm -f "$dmg"
hdiutil create \
    -volname "$volume" \
    -srcfolder "$staging" \
    -fs HFS+ \
    -format UDZO \
    -quiet \
    "$dmg"

# An image nobody can install from is worse than no image: mount the thing that was just
# written and look for the two icons the window is supposed to show.
mount="$(mktemp -d)"
hdiutil attach "$dmg" -mountpoint "$mount" -nobrowse -readonly -quiet

[[ -d "$mount/$(basename "$app")" ]] || {
    echo "error: the image carries no application" >&2
    exit 1
}
[[ -L "$mount/Applications" ]] || {
    echo "error: the image has no Applications shortcut to drag onto" >&2
    exit 1
}
