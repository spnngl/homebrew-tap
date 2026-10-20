# spnngl/homebrew-tap

Homebrew casks for the spnngl apps.

```sh
brew install --cask spnngl/tap/tokenmtr
```

| Cask | App |
| --- | --- |
| `tokenmtr` | [TokenMtr](https://github.com/spnngl/tokenmtr): token usage and cost meter for AI coding agents (macOS 13 or newer). |

## tokenmtr

- The app is signed with the self-signed certificate `TokenMtr Local Signing`, not notarised. The cask removes the quarantine flag so that Gatekeeper does not block the first launch.
- The app's onboarding installs the background daemon (LaunchAgent `dev.tokenmtr.daemon`); the cask cannot, because Homebrew sandboxes install steps. `brew upgrade` keeps the daemon and the app restarts it on the new version at launch.
- `brew uninstall` keeps the daemon: run `tokenmtr service uninstall` first. `brew uninstall --zap` removes it and also deletes the config, the usage store and its backups, and the app's launch-at-login item.
- `tokenmtr` on the `PATH` is the CLI inside `TokenMtr.app`.

## Updates

Renovate opens a pull request for each TokenMtr release. It bumps `version` and `sha256` in `Casks/tokenmtr.rb` and takes the sha256 from the release's `SHA256SUMS` (`renovate.json5`). It merges the pull request once CI has installed the new cask.
