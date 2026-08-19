#!/usr/bin/env bash
set -euo pipefail

failed=0

require() {
  local command=$1
  local install=$2
  if ! command -v "$command" >/dev/null 2>&1; then
    printf 'Missing %s. %s\n' "$command" "$install" >&2
    failed=1
  fi
}

require cargo 'Install Rust with rustup-init.exe from https://rustup.rs, then reopen Git Bash.'
require rustc 'Install Rust with rustup-init.exe from https://rustup.rs, then reopen Git Bash.'
require node 'Install Node.js 24 from https://nodejs.org, then reopen Git Bash.'
require pnpm 'Run: npm install -g pnpm@11.4.0'
require cmake 'Run from PowerShell: winget install --id Kitware.CMake --exact, then reopen Git Bash.'

if [[ $failed -ne 0 ]]; then
  exit 1
fi

if command -v powershell.exe >/dev/null 2>&1; then
  vs_installation=$(powershell.exe -NoProfile -Command \
    '$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"; if (Test-Path $vswhere) { & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath }' \
    | tr -d '\r')
  if [[ -z "$vs_installation" ]]; then
    printf 'Missing Visual Studio C++ Build Tools. Install Visual Studio 2022 Build Tools with Desktop development with C++.\n' >&2
    failed=1
  fi
fi

if [[ $failed -ne 0 ]]; then
  exit 1
fi

rust_version=$(rustc --version | awk '{print $2}')
node_major=$(node --version | sed -E 's/^v([0-9]+).*/\1/')
pnpm_version=$(pnpm --version)

if [[ "$rust_version" != 1.95.0 ]]; then
  printf 'Rust 1.95.0 is required by rust-toolchain.toml; found %s. Run: rustup toolchain install 1.95.0-x86_64-pc-windows-msvc\n' "$rust_version" >&2
  failed=1
fi
if [[ "$node_major" -lt 24 ]]; then
  printf 'Node.js 24+ is required; found %s.\n' "$(node --version)" >&2
  failed=1
fi
if [[ "$pnpm_version" != 11.4.0 ]]; then
  printf 'pnpm 11.4.0 is required; found %s. Run: npm install -g pnpm@11.4.0\n' "$pnpm_version" >&2
  failed=1
fi

if [[ $failed -ne 0 ]]; then
  exit 1
fi

printf 'Windows build prerequisites: PASS\n'
printf 'cargo: %s\n' "$(command -v cargo)"
printf 'rustc: %s\n' "$(command -v rustc)"
printf 'node: %s\n' "$(command -v node)"
printf 'pnpm: %s\n' "$(command -v pnpm)"
printf 'cmake: %s\n' "$(command -v cmake)"
