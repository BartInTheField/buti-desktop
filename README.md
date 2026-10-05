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

The wordmark is `buti`, lowercase, from [BartInTheField/buti](https://github.com/BartInTheField/buti). This repository is the desktop app: the Tauri and Svelte client in `apps/desktop`. It is a fork of [gitbutlerapp/gitbutler](https://github.com/gitbutlerapp/gitbutler), published as [`BartInTheField/buti-desktop`](https://github.com/BartInTheField/buti-desktop). Upstream license notices stay in [`LICENSE.md`](LICENSE.md) (Functional Source License 1.1, with a future MIT grant).

`crates/` is the forked GitButler engine that `apps/desktop` links. It is not a separate CLI or web product. The web app, the Electron app, and the standalone installer are not in this repo. The bundle id stays `com.gitbutler.app`. Desktop updates come from this repo’s GitHub Releases. See [docs/releases.md](docs/releases.md).

```bash
git remote add upstream https://github.com/gitbutlerapp/gitbutler.git
git fetch upstream
git merge upstream/master
```

## What ships

| Path | Role |
| --- | --- |
| `apps/desktop` | Svelte UI (product name **buti**) |
| `crates/gitbutler-tauri` | Tauri shell |
| `packages/ui-svelte`, `shared`, `core`, `but-sdk` | UI and types the desktop app imports |
| `crates/` | Forked GitButler engine the shell links, including the embedded `but` binary |

## Build and run the desktop app

Prerequisites are the upstream desktop setup: Rust, pnpm (it installs Node), and the Tauri system packages listed in [DEVELOPMENT.md](DEVELOPMENT.md).

```bash
git clone https://github.com/BartInTheField/buti-desktop.git
cd buti-desktop
pnpm install
pnpm dev:desktop
```

`pnpm dev:desktop` builds the askpass helper and the embedded `but` binary, then starts the app locally. The product name is **buti**, the same as a release build.

Frontend-only production build of the Tauri UI:

```bash
pnpm build:desktop
```

Release build:

```bash
pnpm tauri build --features builtin-but --config crates/gitbutler-tauri/tauri.conf.release.json
```

There is one channel. The product name is **buti** and the bundle id is `com.gitbutler.app`.

## Releases

GitHub Releases use the same hourly CalVer process as the buti TUI. Tags look like `2026.10.05.1`. The app version the updater compares is `2026.1005.1`. Details, the signing secrets, and how to skip or retract a release are in [docs/releases.md](docs/releases.md).

## Follow-ups

- App icons use the buti mark from `brand/mark.svg`. At 16px the commit dot is dropped, matching the brand note.
- There is no system tray. The dock, taskbar, and window title follow the product name `buti`.
- In-app Help links still open upstream docs and `gitbutlerapp/gitbutler`.
- The shared settings directory name remains `gitbutler`.
- The updater manifest is `latest.json` on the GitHub Release. Prompt copy and a kill switch are still the upstream updater UI.
