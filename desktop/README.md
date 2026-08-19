# Buzz

Desktop chat shell with:

- Tauri + React + TypeScript + Vite
- Tailwind CSS
- shadcn/ui-ready shared components
- Biome (lint/format/check)
- Feature-driven frontend structure

## Prerequisites

Follow the repository's [development toolchain guide](../docs/development-toolchain.md)
before running these commands. Native Windows uses Rustup/Node/pnpm/CMake;
macOS and Linux use the repository's Hermit environment.

To build and install the complete forked desktop app, including native Rust
sidecars, use the platform instructions in the [root README](../README.md#install-buzz-desktop).
`pnpm build` below builds frontend assets only.

## Scripts

- `pnpm dev` - run the web frontend
- `pnpm tauri dev` - run the desktop app
- `pnpm build` - typecheck and build frontend
- `pnpm typecheck` - TypeScript checks
- `pnpm lint` - Biome lint
- `pnpm format` - Biome format (write)
- `pnpm check` - Biome check

## Structure

- `src/shared` - reusable app-wide code (`ui`, `lib`, `styles`)
- `src/features` - feature modules (vertical slices)
- `src/app` - top-level app composition
