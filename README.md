<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="brand/logo.svg">
    <img src="brand/logo-dark-text.svg" alt="buti" width="360">
  </picture>
</p>

<p align="center">
  <strong>Parallel</strong> agentic workflow<br>
  <strong>Code review</strong> your agent can act on<br>
  On top of <strong>GitButler</strong>
</p>

The wordmark is `buti`, lowercase, from [BartInTheField/buti](https://github.com/BartInTheField/buti). This repository is the desktop app: a [Tauri](https://tauri.app/) and Svelte client, plus the Electron desktop client. It is a fork of [gitbutlerapp/gitbutler](https://github.com/gitbutlerapp/gitbutler). The intended repository name is [`BartInTheField/buti-desktop`](https://github.com/BartInTheField/buti-desktop). Upstream license notices stay in [`LICENSE.md`](LICENSE.md) (Functional Source License 1.1, with a future MIT grant).

## Sync with upstream

Bundle ids (`com.gitbutler.app`, `com.gitbutler.lite`), deep-link schemes, and the desktop update feed (`https://app.gitbutler.com`) are unchanged. The desktop publish workflow still targets GitButler’s release bucket. That keeps the installed app on the same identity as upstream, so it can take GitButler desktop updates and this tree can merge upstream commits without rewriting data directories or the updater.

```bash
git remote add upstream https://github.com/gitbutlerapp/gitbutler.git
git fetch upstream
git merge upstream/master
```

Expect conflicts only where this fork’s branding sits: product display names, this README, the top of `DEVELOPMENT.md`, and the disabled CLI-installer / web CI jobs. Shared crates, `apps/desktop`, `apps/lite`, and the desktop CI jobs are meant to merge through.

## What ships

| Kept | Role |
| --- | --- |
| `apps/desktop` + `crates/gitbutler-tauri` | Tauri/Svelte desktop app (product name **buti**) |
| `apps/lite` | Electron desktop app (product name **buti**) |
| Desktop packages (`ui-svelte`, `ui-react`, `shared`, `core`, `but-sdk`, …) | UI and SDK the desktop clients build against |
| Rust workspace members, including `but` | Shared engine. Release builds embed `but` via the `builtin-but` feature. `but-server` still serves the desktop UI in a browser. |

| Not shipped (code kept) | How it is turned off |
| --- | --- |
| Standalone `but` CLI installer (`but-installer`, `scripts/install.sh` publish) | `.github/workflows/push.yaml` installer jobs are `if: false` |
| `apps/web` | `.github/workflows/test-web.yml` no longer runs on push or pull request |

Nothing was deleted from the workspace. Crate names and npm package names stay `@gitbutler/*` / `gitbutler-*` so desktop builds and upstream merges keep working.

## Build and run the desktop app

Prerequisites are the upstream desktop setup: Rust, pnpm (it installs Node), and the Tauri system packages listed in [DEVELOPMENT.md](DEVELOPMENT.md).

Until the GitHub rename, clone this fork as `gitbutler`. After the rename:

```bash
git clone https://github.com/BartInTheField/buti-desktop.git
cd buti-desktop
pnpm install
pnpm dev:desktop
```

`pnpm dev:desktop` builds the askpass helper and the embedded `but` binary, then starts the Tauri dev app. The window title and macOS app menu use **buti Dev**.

Electron desktop:

```bash
pnpm dev:lite
```

Frontend-only production build of the Tauri UI:

```bash
pnpm build:desktop
```

A local installable Tauri build (nightly-style, updater still pointed at GitButler):

```bash
pnpm tauri build --features devtools,builtin-but,disable-auto-updates,nightly --config crates/gitbutler-tauri/tauri.conf.nightly-local.json
```

Release packaging uses `crates/gitbutler-tauri/tauri.conf.release.json`. The product name is **buti**. The bundle id stays `com.gitbutler.app`, so it installs as the same app identity upstream uses.

Browser dev of the same Svelte UI (optional, not a separate product):

```bash
cargo run -p but-server
pnpm dev:desktop-http
```

Open `http://localhost:1420`.

## Follow-ups

- GitHub repository rename to `BartInTheField/buti-desktop`.
- App icons use the buti mark from `brand/mark.svg`. At 16px the commit dot is dropped, matching the brand note.
- There is no system tray. The dock, taskbar, and window title follow the product name `buti`.
- In-app Help links still open upstream docs and `gitbutlerapp/gitbutler`.
- The shared settings directory name remains `gitbutler`.
- `apps/web` and the `but` CLI sources are still in the tree. Re-enable their CI jobs by restoring the upstream `if` conditions when you want them to ship again.
- A buti-owned update server would be a later change. This fork keeps GitButler’s feed on purpose.
