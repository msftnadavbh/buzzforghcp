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

Read the complete installation guide:

**[Install GitHub Copilot CLI for Buzz on macOS, Windows, Linux, or WSL](docs/github-copilot-cli.md)**

The short version:

1. Install GitHub Copilot CLI on the same operating-system side as Buzz.
2. Run `copilot login`.
3. Start this fork's Buzz Desktop build.
4. Open **Settings -> Agent runtimes**.
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

## Build From Source

Prerequisites:

- Docker
- [Hermit](https://cashapp.github.io/hermit/)
- Platform dependencies required by upstream Buzz/Tauri

```bash
git clone https://github.com/msftnadavbh/buzzforghcp.git
cd buzzforghcp
. ./bin/activate-hermit
cp .env.example .env
just setup
just build
```

Run the relay and desktop app together:

```bash
just dev
```

For packaged desktop builds:

```bash
just desktop-build
```

Upstream contributor and platform setup details remain in
[`CONTRIBUTING.md`](CONTRIBUTING.md) and [`TESTING.md`](TESTING.md).

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
