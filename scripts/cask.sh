#!/usr/bin/env bash
set -euo pipefail

version="${1:-}"
repo="${2:-n0sfer/humane-space-tab}"

if [[ -z "$version" ]]; then
    echo "usage: scripts/cask.sh <version> [owner/repo]" >&2
    echo "       writes the Homebrew cask for a packaged version to stdout" >&2
    exit 64
fi

if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "error: '$version' is not MAJOR.MINOR.PATCH" >&2
    exit 64
fi

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
sidecar="$root/dist/HumaneSpaceTab-$version.dmg.sha256"

if [[ ! -f "$sidecar" ]]; then
    echo "error: $sidecar is missing — run scripts/package.sh first" >&2
    exit 1
fi

read -r sum _ <"$sidecar"

cat <<CASK
cask "humane-space-tab" do
  version "$version"
  sha256 "$sum"

  url "https://github.com/$repo/releases/download/v#{version}/HumaneSpaceTab-#{version}.dmg",
      verified: "github.com/$repo/"
  name "Humane Space Tab"
  desc "App switcher that lists only the applications of the current Space"
  homepage "https://github.com/$repo"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :sequoia

  app "Humane Space Tab.app"

  uninstall quit: "io.github.n0sfer666.humane-space-tab"

  zap trash: [
    "~/Library/Preferences/io.github.n0sfer666.humane-space-tab.plist",
  ]

  caveats <<~EOS
    This build is signed ad-hoc: there is no Apple Developer ID behind it, so macOS
    refuses the first launch. Open System Settings › Privacy & Security, scroll to the
    bottom and press "Open Anyway", then launch it again.

    The switcher needs Accessibility. The app asks on launch, and its menu bar icon says
    so until the grant is there. macOS ties that grant to the code signature, so it has
    to be given again after every upgrade.
  EOS
end
CASK
