# spnngl/homebrew-tap

Homebrew casks for the spnngl apps. `README.md` is the users' doc: update it in the same change as
a cask's behaviour (install, upgrade, uninstall, zap).

## Rules

- Pull requests fail CI unless every commit subject is a Conventional Commit
  (`type(scope)!: description`; types feat, fix, docs, style, refactor, perf, test, build, ci,
  chore, revert). Scope: the cask name for a cask change (`fix(tokenmtr): ...`).
- `main` only takes pull requests, rebased. Required checks: `cask`, `Conventional Commits`,
  `Secret Scanning`.
- Renovate bumps `version` and `sha256` of `Casks/tokenmtr.rb` together (regex manager in
  `renovate.json5`): keep the two lines adjacent and in that order.
- Workflows: third-party actions at a full commit SHA with a `# vX.Y.Z` comment; the shared
  `spnngl/.github` workflows at `@main` on purpose (`.github/zizmor.yml` allows it).

## Verifying

Done when all pass:

```sh
brew tap spnngl/tap "$PWD" && brew style spnngl/tap
brew audit --cask --strict --online --except=livecheck_version spnngl/tap/tokenmtr
actionlint
GH_TOKEN="$(gh auth token)" uvx zizmor@<version in spnngl/.github lint-workflows.yml> .
```

A cask change is done once `.github/workflows/ci.yml` passed: it installs the cask on macOS, starts
the daemon and checks that `brew uninstall --zap` removes it.
