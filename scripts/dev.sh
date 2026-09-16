#!/usr/bin/env bash
set -euo pipefail

version="${1:-}"
build="${2:-0}"

if [[ -z "$version" ]]; then
    echo "usage: scripts/dev.sh <version> [build]" >&2
    echo "       builds the Debug bundle and runs it from .build" >&2
    exit 64
fi

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

derived=".build/debug-app"
app="$derived/Build/Products/Debug/Humane Space Tab.app"
log="$derived/xcodebuild.log"

fail() {
    echo "error: $1" >&2
    exit 1
}

echo "==> generating the project"
xcodegen generate --quiet

echo "==> building Debug $version ($build)"
mkdir -p "$derived"
if ! xcodebuild -project HumaneSpaceTab.xcodeproj \
    -scheme HumaneSpaceTab \
    -configuration Debug \
    -destination 'platform=macOS' \
    -derivedDataPath "$derived" \
    MARKETING_VERSION="$version" \
    CURRENT_PROJECT_VERSION="$build" \
    build >"$log" 2>&1; then
    echo "error: the debug build failed" >&2
    tail -n 40 "$log" >&2
    exit 1
fi

[[ -d "$app" ]] || fail "the build left no bundle at $app"

echo "==> stopping the running app"
pkill -x HumaneSpaceTab 2>/dev/null || true
for _ in $(seq 20); do
    pgrep -qx HumaneSpaceTab || break
    sleep 0.25
done
if pgrep -qx HumaneSpaceTab; then
    fail "HumaneSpaceTab is still running; quit it and run this again"
fi

echo "==> launching"
open "$root/$app"
for _ in $(seq 20); do
    if pgrep -qx HumaneSpaceTab; then break; fi
    sleep 0.25
done
pgrep -qx HumaneSpaceTab || fail "$app did not start"

echo "==> $app is $version ($build), running as pid $(pgrep -x HumaneSpaceTab | head -1)"
echo "    This is the Debug bundle, not the one in /Applications, which stays untouched."
echo "    Accessibility has to be granted again: every build carries its own ad-hoc"
echo "    signature, and macOS ties the grant to it."
