# HN05 Homebrew tap

Homebrew formulas for HN05 projects, using GitHub source repositories.

```sh
brew install hn05/tap/shoal          # Tagged release
brew install --HEAD hn05/tap/shoal   # Main instead
```

Homebrew automatically taps `HN05/homebrew-tap` on GitHub. Alternatively, run
`brew tap hn05/tap` once, then use `brew install shoal`.

Initial rollout: the first release tag `v0.1.0` is not published yet. Main builds
require Shoal's packaging PR to be merged and mirrored to GitHub first.

After installing:

```sh
shoal skill install
shoal setup --executable "$(brew --prefix shoal)/bin/shoal"
```

The installed skill follows upgrades automatically. To update:

```sh
brew update
brew upgrade hn05/tap/shoal              # Release
brew upgrade --fetch-HEAD hn05/tap/shoal # Main instead
shoal daemon restart
```

## Maintenance

This repository is maintained at
[HN05/homebrew-tap-github](https://git.henriknordvik.com/HN05/homebrew-tap-github)
and push-mirrored to [HN05/homebrew-tap](https://github.com/HN05/homebrew-tap).
Push changes to Forgejo; do not commit directly to the GitHub mirror.

Project-specific build logic lives in the source repository. Shoal's formula
calls its `scripts/install-homebrew.sh`, which builds the selected version and
packages its skill. Stable releases automatically update the formula through
Shoal's Actions workflow using `HOMEBREW_TAP_TOKEN` with write access to both
Forgejo tap repositories. No GitHub write credential is needed by Shoal's workflow.

The updater verifies that the release tag on GitHub matches the published Shoal
commit before changing this formula. If source mirroring is delayed, rerun
`Update Homebrew release` with the existing tag after the mirror catches up.
The original `HN05/homebrew-tap` on Forgejo separately serves Forgejo source URLs.
