# Releases

buti desktop is published the same way as the [buti](https://github.com/BartInTheField/buti) TUI: once an hour, and again whenever someone runs the workflow by hand. The workflow is [`.github/workflows/release.yml`](../.github/workflows/release.yml).

## Version

The git tag matches buti: `YYYY.MM.DD.N`, UTC. `N` counts the releases of that day.

```text
2026.10.05.1
2026.10.05.2
```

The Tauri app version is semver, because the updater compares semver and rejects a fourth number. The tag `YYYY.MM.DD.N` is stored as `YYYY.MMDD.N` (`month * 100 + day`):

| Git tag | App version in `latest.json` |
| --- | --- |
| `2026.10.05.1` | `2026.1005.1` |
| `2026.01.09.2` | `2026.109.2` |

`gh release create --generate-notes` writes the changelog, same as buti.

## What gets published

For each tag the workflow builds the Tauri app:

| Runner | Updater platform |
| --- | --- |
| `macos-15` | `darwin-aarch64` |
| `macos-15` (`x86_64-apple-darwin`) | `darwin-x86_64` |
| `ubuntu-22.04` | `linux-x86_64` |
| `ubuntu-22.04-arm` | `linux-aarch64` |
| `windows-latest` | `windows-x86_64` |

The GitHub Release holds the installers (`.dmg`, `.deb`, `.rpm`, `.AppImage`, `.msi`), `checksums.txt`, and `latest.json`. The running app reads:

```text
https://github.com/BartInTheField/buti-desktop/releases/latest/download/latest.json
```

`latest.json` lists only platforms that have a minisign signature. The public key baked into the app is the one in `crates/gitbutler-tauri/tauri.conf.json`.

## One-time signing secrets

Updater artifacts are signed. Before the first publish, add these repository secrets:

| Secret | Value |
| --- | --- |
| `TAURI_SIGNING_PRIVATE_KEY` | contents of the minisign secret key |
| `TAURI_SIGNING_PRIVATE_KEY_PASSWORD` | password for that key |

The public key in the app must be the pair of that secret. If the secrets are missing, the workflow still builds installers and uploads them to the Actions run, then stops before creating a Release. That keeps an unsigned build from becoming `latest` and hiding a signed update.

macOS and Windows packages are not notarized or Authenticode-signed unless you also set the Apple and Windows certificate secrets used by `scripts/release.sh --sign`. The hourly workflow does not pass `--sign`. Gatekeeper and SmartScreen will warn on those installers.

## Skip, rehearse, retract

The job does nothing when `HEAD` already has a tag. Two runs cannot take the same version: the workflow uses a `release` concurrency group and does not cancel the one already running.

- **Opt out of the next hour.** Tag the commit and push the tag. Any tag is enough: `git tag no-release && git push origin no-release`.
- **Rehearse.** Actions → Release → Run workflow, with **dry run** enabled. Artifacts land on the workflow run. No GitHub Release is created.
- **Retract a bad release.** `gh release delete <tag> --cleanup-tag --yes`. Then tag that commit (`no-release` is fine) so the next hour does not publish it again. Deleting the tag and leaving the commit untagged lets the next hour publish a new `N`.

## Differences from buti

- buti publishes one Go binary per OS/arch. This workflow publishes the Tauri desktop installers and a `latest.json` the updater can install.
- The git tag is the same CalVer string. The app's own version string is the semver form above.
- The Electron app (`apps/lite`) is not in this workflow. Build it with `.github/workflows/lite.yml` when you want that package.
