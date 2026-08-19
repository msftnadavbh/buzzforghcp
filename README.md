# Buzz for GitHub Copilot CLI

An unofficial source fork of [Block's Buzz](https://github.com/block/buzz) that
adds GitHub Copilot CLI as a native managed agent runtime.

> This is not a new chat application and it is not an official Block or GitHub
> distribution. It is the upstream Buzz application with a focused Copilot CLI
> integration.

## What This Fork Adds

Buzz can launch GitHub Copilot CLI through its native Agent Client Protocol
(ACP) server:

```text
Buzz Desktop -> buzz-acp -> copilot --acp --stdio
```

The integration adds:

- **GitHub Copilot** to Buzz Desktop's agent runtime catalog.
- Automatic detection of `copilot`, `copilot.exe`, and Windows npm shims.
- Official installation commands for macOS/Linux and Windows.
- Correct `--acp --stdio` launch arguments on every platform.
- Buzz-managed process lifecycle and cleanup.
- Copilot authentication-error guidance using `copilot login`.
- A licensed, theme-aware Copilot icon.
- Installation and troubleshooting documentation for macOS, Windows, Linux,
  WSL, and WSLg.

## Start Here

There are two separate installations:

1. Install this fork's **Buzz Desktop application**.
2. Install and authenticate **GitHub Copilot CLI**.

Do them in that order. An upstream Buzz release does not contain this fork's
Copilot runtime integration.

## Install Buzz Desktop

### Important: Build Required

This fork does not currently publish prebuilt DMG, EXE, DEB, or AppImage
releases. You must build the native application once from source.

Do not install a binary from
[`block/buzz` releases](https://github.com/block/buzz/releases) if you want this
integration. Those are upstream builds and do not include this fork's changes.

The commands below build the complete application, including the Rust
`buzz-acp`, `buzz-agent`, `buzz`, and Git credential sidecars. Running only
`just desktop-build` is insufficient: that command builds frontend web assets,
not an installable desktop application.

### Common Setup

Install these on every platform:

- [Git](https://git-scm.com/downloads)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) or Docker
  Engine, if you want to run a local Buzz relay
- [Hermit](https://cashapp.github.io/hermit/) on macOS and Linux. Native
  Windows uses the separately installed toolchain documented below.

Clone this fork:

```bash
git clone https://github.com/msftnadavbh/buzzforghcp.git
cd buzzforghcp
```

On macOS and Linux, `. ./bin/activate-hermit` downloads the pinned Rust,
Node.js, pnpm, and `just` toolchains when first used. Do not run that command in
native Windows Git Bash; this repository's Hermit packages are Unix-only.

### macOS App

Requirements:

- macOS
- Xcode Command Line Tools: `xcode-select --install`

Build the application from Terminal:

```bash
set -e
. ./bin/activate-hermit
command -v cargo rustc pnpm
pnpm install
cargo build --release \
  -p buzz-acp -p buzz-agent -p buzz-backend-kubernetes \
  -p buzz-dev-mcp -p git-credential-nostr -p buzz-cli
./scripts/bundle-sidecars.sh
pnpm --dir desktop tauri build --bundles dmg --features mesh-llm
```

The installer is created under:

```text
desktop/src-tauri/target/release/bundle/dmg/
```

Open the `.dmg`, drag **Buzz** into **Applications**, then launch Buzz. This is
an unsigned local build, so macOS may require **System Settings -> Privacy &
Security -> Open Anyway** on first launch.

This fork uses the same application identifier and name as upstream Buzz.
Installing it replaces an existing upstream Buzz installation in
**Applications**; it does not install side by side.

### Windows App

Requirements:

- Windows 10 or Windows 11
- [Git for Windows](https://git-scm.com/download/win), including Git Bash
- Microsoft C++ Build Tools with **Desktop development with C++**
- Microsoft Edge WebView2 Runtime
- [Rustup for Windows](https://rustup.rs/) using the MSVC toolchain
- [Node.js 24](https://nodejs.org/)
- pnpm 11.4.0: `npm install -g pnpm@11.4.0`
- Docker Desktop, if running a local relay

After installing them, close and reopen Git Bash. Do **not** source
`bin/activate-hermit` on Windows. Verify the native tools and build:

```bash
set -e
rustup toolchain install 1.95.0-x86_64-pc-windows-msvc
rustup default 1.95.0-x86_64-pc-windows-msvc
npm install -g pnpm@11.4.0
./scripts/check-windows-build-prereqs.sh
export CMAKE_POLICY_VERSION_MINIMUM=3.5
pnpm install
cargo build --release \
  -p buzz-acp -p buzz-agent -p buzz-dev-mcp \
  -p git-credential-nostr -p buzz-cli
./scripts/bundle-sidecars.sh
pnpm --dir desktop tauri build --bundles nsis
```

The installer is created under:

```text
desktop/src-tauri/target/release/bundle/nsis/
```

Run the generated `*-setup.exe`. The local build is unsigned, so Windows
SmartScreen may show **Windows protected your PC**. Choose **More info -> Run
anyway** only if you built the installer yourself from this checkout.

This fork uses the same application identifier and name as upstream Buzz. The
installer replaces an existing upstream Buzz installation rather than creating
a separate app.

### Linux App

On Debian or Ubuntu, install the native Tauri dependencies:

```bash
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  build-essential curl file libasound2-dev libayatana-appindicator3-dev \
  libgtk-3-dev librsvg2-dev libssl-dev libwebkit2gtk-4.1-dev libxdo-dev \
  patchelf wget
```

Build the application:

```bash
set -e
. ./bin/activate-hermit
command -v cargo rustc pnpm
pnpm install
cargo build --release \
  -p buzz-acp -p buzz-agent -p buzz-backend-kubernetes \
  -p buzz-dev-mcp -p git-credential-nostr -p buzz-cli
./scripts/bundle-sidecars.sh
pnpm --dir desktop tauri build --bundles deb,appimage --features mesh-llm
```

Artifacts are created under:

```text
desktop/src-tauri/target/release/bundle/deb/
desktop/src-tauri/target/release/bundle/appimage/
```

Install the DEB:

```bash
sudo apt install ./desktop/src-tauri/target/release/bundle/deb/*.deb
```

Or run the AppImage:

```bash
chmod +x desktop/src-tauri/target/release/bundle/appimage/*.AppImage
./desktop/src-tauri/target/release/bundle/appimage/*.AppImage
```

### WSL

Use the **Windows app instructions** above. Build and install Buzz from Git
Bash or PowerShell on Windows, not from inside WSL.

The recommended arrangement is:

```text
Windows Buzz Desktop + Windows GitHub Copilot CLI
```

Building the Linux GUI inside WSLg is possible as a developer experiment, but
it requires the Linux dependency and build steps and is not the recommended
Windows installation. A Windows Buzz process cannot launch a Copilot CLI that
exists only inside WSL.

#### Git Bash shows only a global pnpm path

This is expected before installing the native Windows build prerequisites.
`command -v cargo rustc pnpm` prints only commands it can find; your output:

```text
/c/Users/nadavbh/AppData/Roaming/npm/pnpm
```

means `cargo` and `rustc` are missing, while pnpm is already installed globally.
Install Rustup, then pin pnpm to the repository's required version:

```bash
rustup toolchain install 1.95.0-x86_64-pc-windows-msvc
rustup default 1.95.0-x86_64-pc-windows-msvc
npm install -g pnpm@11.4.0
./scripts/check-windows-build-prereqs.sh
```

The repository's `.npmrc` disables pnpm's redundant package-manager
self-switch, avoiding the registry-signature error after the pinned pnpm is
installed directly.

The full toolchain reference is
[`docs/development-toolchain.md`](docs/development-toolchain.md).

### First Launch

Buzz is a client for a Buzz relay/community. After installing the desktop app:

1. Launch Buzz.
2. Connect to a community URL shared by its operator, or run a local relay.
3. Complete identity and community onboarding.

For a local development relay on macOS/Linux, return to the repository root
and run:

```bash
. ./bin/activate-hermit
cp .env.example .env
just setup
just dev
```

On native Windows, first install `just` from the
[toolchain guide](docs/development-toolchain.md), then run from Git Bash:

```bash
cp .env.example .env
just setup
just dev
```

`just setup` starts Postgres, Redis, and the other local services with Docker.
`just dev` starts the relay and opens an uninstalled development build of Buzz.

## Install GitHub Copilot CLI

After Buzz Desktop is installed, follow the complete platform guide:

**[Install GitHub Copilot CLI for Buzz on macOS, Windows, Linux, or WSL](docs/github-copilot-cli.md)**

Then:

1. Run `copilot login` on the same operating-system side as Buzz.
2. Restart Buzz so it receives any PATH changes.
3. Open **Settings -> Agent runtimes**.
4. Find **GitHub Copilot** and use **Check again** if necessary.
5. Select **GitHub Copilot** when creating or editing an agent.

## Platform Commands

### macOS

```bash
brew install --cask copilot-cli
copilot login
```

### Windows

```powershell
winget install --id GitHub.Copilot --exact
copilot login
```

### Linux and WSL

```bash
curl -fsSL https://gh.io/copilot-install | bash
copilot login
```

For WSL, read the guide before installing. Native Windows Buzz cannot discover
a Copilot executable installed only inside WSL.

## Why Is This a Full Buzz Repository?

Because the integration changes the application itself.

Buzz Desktop is a Tauri/React application backed by Rust binaries. Adding a
runtime requires coordinated changes to:

- Desktop runtime discovery and installation.
- ACP process launch and argument normalization.
- Managed-agent lifecycle and cleanup.
- Desktop UI assets.
- Tests, documentation, and release packaging inputs.

A repository containing only a wrapper script or Markdown guide could explain
how to run Copilot, but it could not build a Buzz Desktop application with
**GitHub Copilot** in the runtime picker. The full source tree is therefore
intentional.

If you only need the instructions and do not intend to build Buzz, you only
need this file:

**[`docs/github-copilot-cli.md`](docs/github-copilot-cli.md)**

## Fork-Specific Files

Most files are unchanged upstream Buzz source. The Copilot integration is
concentrated in these locations:

| Path | Purpose |
|---|---|
| `desktop/src-tauri/src/managed_agents/discovery/copilot.rs` | Copilot runtime metadata and platform installers |
| `desktop/src-tauri/src/managed_agents/discovery.rs` | Registers the compiled runtime and launch arguments |
| `desktop/src-tauri/src/managed_agents/runtime/process.rs` | Managed process recognition and cleanup |
| `desktop/src/features/onboarding/ui/HarnessMarks.tsx` | Copilot runtime icon |
| `crates/buzz-acp/src/config.rs` | Standalone ACP argument normalization |
| `crates/buzz-acp/src/lib.rs` | Copilot authentication failure handling |
| `docs/github-copilot-cli.md` | Complete installation and troubleshooting guide |

Use the Git history to inspect the complete fork diff.

## Verify the Integration

First verify Copilot independently:

```bash
copilot --version
copilot -p "Reply with exactly: COPILOT_OK" --allow-all-tools
```

Then run the relevant project checks:

```bash
cargo test -p buzz-acp
cargo clippy -p buzz-acp --all-targets -- -D warnings
pnpm --dir desktop typecheck
pnpm --dir desktop check:file-sizes
```

In Buzz Desktop, create an agent using the **GitHub Copilot** runtime, add it to
a channel, start it, and mention it with a small task.

## Current Scope

Included:

- Local managed agents on macOS, Windows, and Linux.
- Native Windows and WSL-local deployment patterns.
- Stored `copilot login` credentials and supported token environment variables.
- ACP prompts, tools, cancellation, model metadata, and streaming handled by
  Buzz's existing generic ACP client.

Not included:

- Prebuilt releases from this fork.
- An embedded Copilot CLI binary.
- A custom GitHub OAuth application.
- Automatic validation of Copilot subscription status. Copilot CLI does not
  expose a documented non-interactive login-status command.
- Official support from Block or GitHub.

## Relationship to Upstream

- Upstream project: https://github.com/block/buzz
- This fork: https://github.com/msftnadavbh/buzzforghcp
- Original feature request: https://github.com/block/buzz/issues/3592

Upstream Buzz contains the relay, desktop and mobile clients, agent harnesses,
CLI, workflows, Git integration, and all other product functionality in this
repository. Refer to upstream for the general Buzz product overview and active
development.

## Security

Copilot runs as a local coding agent and may read files, modify the workspace,
and execute commands with the permissions of the user running Buzz. Use trusted
repositories, review changes, protect credentials, and configure Copilot's
sandbox and tool restrictions appropriately.

Buzz automatically chooses ACP's one-time approval option for requested tools.
Organization and sandbox policies may still deny operations.

## License

The repository retains upstream Buzz's Apache 2.0 license and third-party
notices. The GitHub Copilot Octicon used by this fork is sourced from Primer
Octicons under the MIT license; provenance is recorded in
`desktop/public/harness-logos/CREDITS.md`.
