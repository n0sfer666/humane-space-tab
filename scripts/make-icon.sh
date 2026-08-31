#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

icns="Resources/AppIcon.icns"
staging="$(mktemp -d)/AppIcon.iconset"
trap 'rm -rf "$(dirname "$staging")"' EXIT

echo "==> drawing"
mkdir -p "$staging" Resources
swift scripts/icon.swift "$staging"

echo "==> packing $icns"
iconutil --convert icns --output "$icns" "$staging"

sizes="$(iconutil --convert iconset --output "$(dirname "$staging")/check.iconset" "$icns" && ls "$(dirname "$staging")/check.iconset" | wc -l | tr -d ' ')"
[[ "$sizes" == "10" ]] || {
    echo "error: $icns carries $sizes images, not the 10 sizes macOS asks for" >&2
    exit 1
}

echo "==> $icns ($(du -h "$icns" | cut -f1), $sizes sizes)"
