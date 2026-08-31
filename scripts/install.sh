#!/usr/bin/env bash
set -euo pipefail

version="${1:-}"
build="${2:-0}"

if [[ -z "$version" ]]; then
    echo "usage: scripts/install.sh <version> [build]" >&2
    echo "       builds the Release bundle and installs it into /Applications" >&2
    exit 64
fi

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

destination="/Applications"
installed="$destination/Humane Space Tab.app"
legacy="$destination/HumaneSpaceTab.app"
zip="dist/HumaneSpaceTab-$version.zip"

fail() {
    echo "error: $1" >&2
    exit 1
}

scripts/package.sh "$version" "$build"

[[ -w "$destination" ]] || fail "$destination is not writable by $(id -un)"

echo "==> stopping the running app"
pkill -x HumaneSpaceTab 2>/dev/null || true
for _ in $(seq 20); do
    pgrep -qx HumaneSpaceTab || break
    sleep 0.25
done
if pgrep -qx HumaneSpaceTab; then
    fail "HumaneSpaceTab is still running; quit it and run this again"
fi

echo "==> installing into $destination"
rm -rf "$installed" "$legacy"
ditto -x -k "$zip" "$destination"
[[ -d "$installed" ]] || fail "$zip did not unpack into $installed"

plist="$installed/Contents/Info.plist"
installed_version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$plist")"
[[ "$installed_version" == "$version" ]] || fail "$installed says $installed_version, not $version"

echo "==> launching"
open -a "$installed"
for _ in $(seq 20); do
    if pgrep -qx HumaneSpaceTab; then break; fi
    sleep 0.25
done
pgrep -qx HumaneSpaceTab || fail "$installed did not start"

echo "==> $installed is $version, running as pid $(pgrep -x HumaneSpaceTab | head -1)"
echo "    Accessibility has to be granted again: every build carries its own ad-hoc"
echo "    signature, and macOS ties the grant to it. Menu bar icon → Grant Accessibility…"
