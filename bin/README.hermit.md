# Hermit environment

This is a [Hermit](https://github.com/cashapp/hermit) bin directory.

This repository uses these Hermit packages on macOS and Linux only. Native
Windows Git Bash must use Rustup/Node/pnpm/CMake from
[`docs/development-toolchain.md`](../docs/development-toolchain.md) and must not
source `bin/activate-hermit`.

The symlinks in this directory are managed by Hermit and will automatically
download and install Hermit itself as well as packages. These packages are
local to this environment.
