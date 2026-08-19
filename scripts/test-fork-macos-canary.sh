#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
WORKFLOW="$ROOT/.github/workflows/fork-macos-canary.yml"

require() {
  local pattern=$1
  local message=$2
  if ! grep -Fq -- "$pattern" "$WORKFLOW"; then
    printf '%s\n' "$message" >&2
    exit 1
  fi
}

require "github.repository == 'msftnadavbh/buzzforghcp'" \
  'macOS canary must be scoped to the fork.'
require 'TARGET: aarch64-apple-darwin' \
  'macOS canary must build Apple Silicon explicitly.'
require 'cargo build --release --target "$TARGET"' \
  'Sidecars must use the matrix target.'
require './scripts/bundle-sidecars.sh "$TARGET"' \
  'Bundling must use target-qualified sidecars.'
require 'pnpm tauri build --verbose --no-sign --target "$TARGET" --bundles dmg' \
  'Tauri must build an explicitly unsigned target-qualified DMG.'
require 'cargo update -p buzz-desktop' \
  'Canary version patching must not update the entire dependency graph.'
require 'createUpdaterArtifacts":false' \
  'Fork canaries must not create upstream updater artifacts.'

if grep -Fq -- '--features mesh-llm' "$WORKFLOW"; then
  printf 'Copilot macOS canary must not pull in optional MeshLLM native builds.\n' >&2
  exit 1
fi

if grep -Fq -- 'x86_64-apple-darwin' "$WORKFLOW"; then
  printf 'Copilot macOS canary must only build Apple Silicon.\n' >&2
  exit 1
fi

printf 'Fork macOS canary contract: PASS\n'
