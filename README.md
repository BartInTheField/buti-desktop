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

The wordmark is `buti`, lowercase, from [BartInTheField/buti](https://github.com/BartInTheField/buti). This repository is the desktop app: a [Tauri](https://tauri.app/) and Svelte client, plus the Electron desktop client. It is a fork of [gitbutlerapp/gitbutler](https://github.com/gitbutlerapp/gitbutler), published as [`BartInTheField/buti-desktop`](https://github.com/BartInTheField/buti-desktop). Upstream license notices stay in [`LICENSE.md`](LICENSE.md) (Functional Source License 1.1, with a future MIT grant).

The web app and the standalone CLI installer are not part of this repo. The Rust workspace stays, because the desktop app embeds `but`. Bundle ids remain `com.gitbutler.app` and `com.gitbutler.lite`.

```bash
git remote add upstream https://github.com/gitbutlerapp/gitbutler.git
git fetch upstream
git merge upstream/master
```

## What ships

| Path | Role |
| --- | --- |
| `apps/desktop` + `crates/gitbutler-tauri` | Tauri/Svelte desktop app (product name **buti**) |
| `apps/lite` | Electron desktop app (product name **buti**) |
| Desktop packages (`ui-svelte`, `ui-react`, `shared`, `core`, `but-sdk`, …) | UI and SDK the desktop clients build against |
| Rust workspace, including `but` | Engine embedded in release builds via the `builtin-but` feature |

## Build and run the desktop app

Prerequisites are the upstream desktop setup: Rust, pnpm (it installs Node), and the Tauri system packages listed in [DEVELOPMENT.md](DEVELOPMENT.md).

```bash
git clone https://github.com/BartInTheField/buti-desktop.git
cd buti-desktop
pnpm install
pnpm dev:desktop
```

`pnpm dev:desktop` builds the askpass helper and the embedded `but` binary, then starts the app locally. The product name is **buti**, the same as a release build.

Electron desktop:

```bash
pnpm dev:lite
```

Frontend-only production build of the Tauri UI:

```bash
pnpm build:desktop
```

Release build:

```bash
pnpm tauri build --features builtin-but --config crates/gitbutler-tauri/tauri.conf.release.json
```

There is one channel. The product name is **buti** and the bundle id is `com.gitbutler.app`, so it stays the same app identity as upstream GitButler releases. The updater still points at GitButler’s release feed.

Browser dev of the same Svelte UI (optional, not a separate product):

```bash
cargo run -p but-server
pnpm dev:desktop-http
```

Open `http://localhost:1420`.

## Follow-ups

- App icons use the buti mark from `brand/mark.svg`. At 16px the commit dot is dropped, matching the brand note.
- There is no system tray. The dock, taskbar, and window title follow the product name `buti`.
- In-app Help links still open upstream docs and `gitbutlerapp/gitbutler`.
- The shared settings directory name remains `gitbutler`.
- A buti-owned update server would be a later change. This fork keeps GitButler’s feed on purpose.
