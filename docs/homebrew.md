# Homebrew

## Installing

```sh
brew install --cask n0sfer666/tap/humane-space-tab
```

Homebrew adds the tap on first use, downloads the release image, verifies its SHA-256
against the cask and moves the app into `/Applications`.

Two things it cannot do for you, both consequences of ad-hoc signing:

- **The first launch is refused.** Open **System Settings → Privacy & Security**, scroll
  to the bottom and press **Open Anyway**. Homebrew prints the same thing as a caveat.
- **Accessibility has to be granted after every upgrade**, because macOS ties the grant to
  the code signature and each build carries its own.

Upgrading and removing are the usual commands:

```sh
brew upgrade --cask humane-space-tab
brew uninstall --cask humane-space-tab      # add --zap to take the preferences too
```

## Publishing (maintainers)

The cask is not written by hand. `scripts/cask.sh` builds it from a packaged version,
reading the image's SHA-256 out of `dist/`:

```sh
scripts/package.sh 0.1.0
scripts/cask.sh 0.1.0 > humane-space-tab.rb
```

It lives in a tap of its own — a repository named `homebrew-tap` under the same owner, so
that `n0sfer666/tap/humane-space-tab` resolves to `github.com/n0sfer666/homebrew-tap`. Casks go
in `Casks/`, and nothing else is required of the repository.

### One-time setup

1. Create a public repository `homebrew-tap` under the owner of this one.
2. Commit `Casks/humane-space-tab.rb` — the file the script just wrote.
3. Give the release workflow a way in: a fine-grained personal access token scoped to that
   one repository with **Contents: read and write**, stored here as the `TAP_TOKEN`
   repository secret. If the tap is not named `homebrew-tap`, set the `TAP_REPO`
   repository variable to `owner/name` as well.

After that every `v*` tag updates the cask: the release job writes the version and the new
SHA-256 into `Casks/humane-space-tab.rb` and pushes. Without the secret the job says so and
carries on — the release is published either way, and the cask can be updated by hand.
Whitespace around a pasted token is stripped before it is used: with it in the URL `git clone`
fails with `URL rejected: Malformed input to a URL function`, which reads like a broken tap
rather than a broken paste.

### Checking a cask before it ships

Homebrew only loads casks that live in a tap, so audit it through a scratch one:

```sh
brew tap-new n0sfer666/casktest --no-git
cp humane-space-tab.rb "$(brew --repository)/Library/Taps/n0sfer666/homebrew-casktest/Casks/"
brew audit --cask n0sfer666/casktest/humane-space-tab
brew untap n0sfer666/casktest
```

`brew audit` says nothing when it is happy.
