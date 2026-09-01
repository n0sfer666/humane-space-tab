#!/usr/bin/env bash
set -euo pipefail

version="${1:-}"
build="${2:-0}"

if [[ -z "$version" ]]; then
    echo "usage: scripts/package.sh <version> [build]" >&2
    echo "       version is MAJOR.MINOR.PATCH, as in 0.1.0" >&2
    exit 64
fi

if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "error: '$version' is not MAJOR.MINOR.PATCH" >&2
    exit 64
fi

if [[ ! "$build" =~ ^[0-9]+$ ]]; then
    echo "error: '$build' is not a build number" >&2
    exit 64
fi

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

derived=".build/release"
app="$derived/Build/Products/Release/Humane Space Tab.app"
plist="$app/Contents/Info.plist"
binary="$app/Contents/MacOS/HumaneSpaceTab"
log="$derived/xcodebuild.log"
dist="dist"
name="HumaneSpaceTab-$version.zip"
zip="$dist/$name"
image="HumaneSpaceTab-$version.dmg"
dmg="$dist/$image"
required_archs=(arm64 x86_64)

fail() {
    echo "error: $1" >&2
    exit 1
}

echo "==> generating the project"
xcodegen generate --quiet

echo "==> building Release $version ($build)"
rm -rf "$derived"
mkdir -p "$derived"
if ! xcodebuild -project HumaneSpaceTab.xcodeproj \
    -scheme HumaneSpaceTab \
    -configuration Release \
    -destination 'generic/platform=macOS' \
    -derivedDataPath "$derived" \
    MARKETING_VERSION="$version" \
    CURRENT_PROJECT_VERSION="$build" \
    build >"$log" 2>&1; then
    echo "error: the release build failed" >&2
    tail -n 40 "$log" >&2
    exit 1
fi

echo "==> checking the bundle"

[[ -f "$binary" ]] || fail "$binary is missing"

built_version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$plist")"
[[ "$built_version" == "$version" ]] || fail "the bundle says $built_version, not $version"
built_build="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$plist")"
[[ "$built_build" == "$build" ]] || fail "the bundle is build $built_build, not $build"

icon="$app/Contents/Resources/AppIcon.icns"
[[ -f "$icon" ]] || fail "the bundle carries no icon — run scripts/make-icon.sh"
named_icon="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIconFile' "$plist")"
[[ "$named_icon" == "AppIcon" ]] || fail "the bundle asks for icon '$named_icon', not AppIcon"

archs="$(lipo -archs "$binary")"
for arch in "${required_archs[@]}"; do
    [[ " $archs " == *" $arch "* ]] || fail "the binary has no $arch slice, only: $archs"
done

for arch in $archs; do
    if ! entitlements="$(codesign -d --arch "$arch" --entitlements - "$app" 2>&1)"; then
        echo "$entitlements" >&2
        fail "codesign could not read the $arch slice"
    fi
    [[ "$entitlements" != *"[Key]"* ]] || {
        echo "$entitlements" >&2
        fail "the $arch slice carries entitlements"
    }

    if ! signature="$(codesign -dv --arch "$arch" "$app" 2>&1)"; then
        echo "$signature" >&2
        fail "codesign could not describe the $arch slice"
    fi
    [[ "$signature" =~ flags=[^[:space:]]*runtime ]] || {
        echo "$signature" >&2
        fail "the $arch slice has no hardened runtime"
    }
done

while IFS= read -r -d '' candidate; do
    kind="$(file -b "$candidate")"
    [[ "$kind" == *Mach-O* ]] || continue
    links="$(otool -arch all -L "$candidate")"
    while IFS= read -r line; do
        [[ "$line" == [[:space:]]* ]] || continue
        [[ "$line" =~ ^[[:space:]]+(/System/Library/Frameworks/|/usr/lib/) ]] && continue
        fail "$candidate links a non-system library:$line"
    done <<<"$links"
done < <(find "$app" -type f -perm -u+x -print0)

codesign --verify --strict --deep "$app"

echo "==> packing"
mkdir -p "$dist"
rm -f "$zip" "$zip.sha256" "$dmg" "$dmg.sha256"
ditto -c -k --keepParent "$app" "$zip"
"$root/scripts/dmg.sh" "$app" "$dmg"

(cd "$dist" && shasum -a 256 "$name" | tee "$name.sha256")
(cd "$dist" && shasum -a 256 "$image" | tee "$image.sha256")
echo "==> $zip"
echo "==> $dmg"
