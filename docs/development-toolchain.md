# Development Toolchain

Use the toolchain for the operating system where the process will run. Native
Windows and WSL are separate environments.

## macOS and Linux

The repository's Hermit environment supplies Rust, Node.js, pnpm, CMake, and
`just`:

```bash
. ./bin/activate-hermit
command -v cargo rustc node pnpm cmake just
```

The paths should point into this checkout's `bin/` directory. Hermit packages
in this repository are Unix packages; do not use them from native Windows Git
Bash.

Linux desktop builds also require the system GTK/WebKit dependencies listed in
[CONTRIBUTING.md](../CONTRIBUTING.md#linux-tauri-system-libraries).

## Native Windows

Install these before building any Rust crate or the desktop application:

1. [Git for Windows](https://git-scm.com/download/win), including Git Bash.
2. Microsoft Visual Studio 2022 Build Tools with **Desktop development with
   C++** and a Windows 10/11 SDK.
3. [Microsoft Edge WebView2 Runtime](https://developer.microsoft.com/microsoft-edge/webview2/).
4. [Rustup for Windows](https://rustup.rs/).
5. [Node.js 24](https://nodejs.org/).
6. [CMake](https://cmake.org/download/) on PATH.
7. pnpm 11.4.0.
8. `just` 1.46.0 if running repository recipes such as `just setup` or
   `just dev`.

Useful package-manager commands from an elevated PowerShell terminal:

```powershell
winget install --id Microsoft.VisualStudio.2022.BuildTools --exact
winget install --id Kitware.CMake --exact
```

In the Visual Studio installer, ensure **Desktop development with C++** is
selected. WebView2 is normally present on current Windows versions; install it
from Microsoft's page if Tauri reports it missing.

Install and select the repository's Rust and pnpm versions:

```bash
rustup toolchain install 1.95.0-x86_64-pc-windows-msvc
rustup default 1.95.0-x86_64-pc-windows-msvc
npm install -g pnpm@11.4.0
cargo install just --version 1.46.0 --locked
```

Close and reopen Git Bash, then verify:

```bash
./scripts/check-windows-build-prereqs.sh
cmake --version
```

The checker should print `Windows build prerequisites: PASS`. A pnpm path such
as `/c/Users/NAME/AppData/Roaming/npm/pnpm` is valid. `cargo` and `rustc` are
normally under `/c/Users/NAME/.cargo/bin/`.

The root `.npmrc` disables pnpm's package-manager self-switch. This repository
installs the required pnpm version directly, avoiding a redundant registry
signature check.

## WSL

- To build the native Windows Buzz app, use the native Windows toolchain above
  from Git Bash. Do not build it from WSL.
- To build Linux binaries inside WSL, install Rust/Node tools inside that WSL
  distribution and use the Linux instructions. Those binaries are Linux
  binaries and cannot replace the Windows desktop app.
- Windows Buzz can launch only a Windows-visible agent runtime. Install GitHub
  Copilot CLI on Windows, not only inside WSL.

## Quick Verification

```bash
cargo --version
rustc --version
node --version
pnpm --version
cmake --version
```

Required versions for this fork are recorded in `rust-toolchain.toml`,
`package.json`, and the repository's Hermit package links.
