# GitHub Copilot CLI in Buzz

Buzz can run GitHub Copilot CLI as a managed coding agent through Copilot's
native Agent Client Protocol (ACP) server:

```text
Buzz Desktop -> buzz-acp -> copilot --acp --stdio
```

This guide covers macOS, Windows, Linux, and Windows Subsystem for Linux (WSL).

## Requirements

- Buzz Desktop built from this fork. Follow
  [Install Buzz Desktop](../README.md#install-buzz-desktop) first. Upstream Buzz
  release binaries do not include this Copilot integration.
- An active GitHub Copilot subscription.
- GitHub Copilot CLI allowed by your organization or enterprise policy.
- A supported GitHub Copilot CLI installation on the same operating-system
  boundary as Buzz Desktop.

Copilot's ACP server is currently public preview. Keep Copilot CLI updated and
retest the connection after upgrades.

## macOS

### Install Copilot CLI

Homebrew is the simplest option:

```bash
brew install --cask copilot-cli
```

Alternatively, use GitHub's install script:

```bash
curl -fsSL https://gh.io/copilot-install | bash
```

Or use npm with Node.js 22 or later:

```bash
npm install -g @github/copilot
```

Buzz searches the common macOS locations `/opt/homebrew/bin`,
`/usr/local/bin`, and `~/.local/bin`, along with the user's login-shell PATH.

### Authenticate and verify

```bash
copilot login
copilot --version
copilot -p "Reply with exactly: COPILOT_OK" --allow-all-tools
```

For GitHub Enterprise Cloud with data residency:

```bash
copilot login --host https://example.ghe.com
```

## Windows

### Requirements

- Windows 10 or Windows 11.
- PowerShell 6 or later.

### Install Copilot CLI

Run in PowerShell:

```powershell
winget install --id GitHub.Copilot --exact
```

Alternatively, install through npm with Node.js 22 or later:

```powershell
npm install -g @github/copilot
```

Buzz resolves native `copilot.exe` installations and npm-generated
`copilot.cmd` or `copilot.bat` shims, including the standard `%APPDATA%\npm`
directory.

Close and reopen Buzz after installation so the Windows GUI process receives
the updated PATH.

### Authenticate and verify

Run in PowerShell:

```powershell
copilot login
copilot --version
copilot -p "Reply with exactly: COPILOT_OK" --allow-all-tools
```

For GitHub Enterprise Cloud with data residency:

```powershell
copilot login --host https://example.ghe.com
```

## Linux

### Install Copilot CLI

Use GitHub's install script:

```bash
curl -fsSL https://gh.io/copilot-install | bash
```

The non-root installer defaults to `~/.local/bin`. To install system-wide:

```bash
curl -fsSL https://gh.io/copilot-install | sudo bash
```

Homebrew and npm are also supported:

```bash
brew install --cask copilot-cli

# Or, with Node.js 22+:
npm install -g @github/copilot
```

### Authenticate and verify

```bash
copilot login
copilot --version
copilot -p "Reply with exactly: COPILOT_OK" --allow-all-tools
```

If Copilot was installed to `~/.local/bin`, confirm that it is executable:

```bash
command -v copilot
```

## WSL

Windows and WSL are separate process and filesystem environments. Pick one of
the following setups and keep both Buzz Desktop and Copilot CLI on the same
side of that boundary.

### Recommended: Windows Buzz with Windows Copilot

If Buzz Desktop is installed as a normal Windows application, install and
authenticate Copilot in Windows PowerShell:

```powershell
winget install --id GitHub.Copilot --exact
copilot login
```

A Copilot binary installed only inside WSL is not visible to Windows Buzz and
will not appear in **Settings -> Agent runtimes**.

Copilot launched by Windows Buzz can still work on a repository stored in WSL
when that repository is exposed through a `\\wsl$\DISTRO\...` path, subject to
Copilot's filesystem and sandbox policies. For the most predictable tool and
Git behavior, keep active repositories on the same side as the agent process.

### Advanced: Linux Buzz under WSLg

If running the Linux Buzz desktop build inside a WSL distribution with WSLg,
install the Linux Copilot CLI inside that same distribution:

```bash
curl -fsSL https://gh.io/copilot-install | bash
copilot login
command -v copilot
```

Then launch the Linux Buzz build from that WSL shell. A Windows Copilot
installation is not automatically visible to Linux Buzz running inside WSL.
Running Buzz Desktop under WSLg is a developer setup; native Windows Buzz is
the recommended Windows configuration.

### Headless WSL agents

For a headless `buzz-acp` process inside WSL, install Copilot in WSL and set the
agent command explicitly:

```bash
export BUZZ_PRIVATE_KEY="nsec1..."
export BUZZ_RELAY_URL="wss://your-community.example"
export BUZZ_ACP_AGENT_COMMAND="copilot"
export BUZZ_ACP_AGENT_ARGS="--acp,--stdio"

buzz-acp
```

All credentials and the Copilot login must exist inside that WSL distribution.

## Configure Buzz Desktop

1. Start or restart Buzz Desktop after installing Copilot CLI.
2. Open **Settings -> Agent runtimes**.
3. Find **GitHub Copilot**.
4. If it is missing, use **Check again** after confirming `copilot --version`
   works in the platform's native terminal.
5. Create or edit an agent and choose **GitHub Copilot** as its harness.
6. Add the agent to a channel and start it.
7. Mention the agent with a small task.

Buzz launches the runtime as:

```text
copilot --acp --stdio
```

Buzz injects the agent's relay URL, Nostr identity, and Buzz CLI path into the
managed process. Copilot can then use the `buzz` CLI to read and write channel
content as that agent.

## Verify ACP directly

The following Node.js smoke test requires Node.js 18 or later. It verifies ACP
initialization without making a model request:

```bash
node - <<'NODE'
const { spawn } = require("node:child_process");

const child = spawn("copilot", ["--acp", "--stdio"], {
  stdio: ["pipe", "pipe", "inherit"],
});

let buffer = "";
const timeout = setTimeout(() => {
  console.error("Copilot ACP initialization timed out");
  child.kill();
  process.exit(1);
}, 30000);

child.stdout.on("data", (chunk) => {
  buffer += chunk;
  const newline = buffer.indexOf("\n");
  if (newline < 0) return;

  const response = JSON.parse(buffer.slice(0, newline));
  clearTimeout(timeout);
  console.log(response.result);
  child.kill();
});

child.stdin.write(`${JSON.stringify({
  jsonrpc: "2.0",
  id: 0,
  method: "initialize",
  params: {
    protocolVersion: 2,
    clientCapabilities: {},
    clientInfo: { name: "buzz-copilot-smoke", version: "1.0.0" },
  },
})}\n`);
NODE
```

A successful response includes `agentInfo.name` set to `Copilot`. Copilot may
negotiate ACP protocol version 1 when Buzz offers version 2; Buzz supports that
fallback.

## Authentication alternatives

For non-interactive environments, Copilot checks these variables in order:

1. `COPILOT_GITHUB_TOKEN`
2. `GH_TOKEN`
3. `GITHUB_TOKEN`
4. Stored `copilot login` credentials
5. GitHub CLI's `gh auth token` fallback

Supported tokens include OAuth tokens and user-owned fine-grained personal
access tokens with the **Copilot Requests** account permission. Classic `ghp_`
personal access tokens are not supported.

Do not save GitHub tokens in Buzz persona definitions or commit them to the
repository. Prefer the operating-system credential store populated by
`copilot login`.

## Upgrade

```bash
copilot update
```

Or update through the original package manager:

```bash
# macOS/Linux Homebrew
brew upgrade --cask copilot-cli

# Windows
winget upgrade --id GitHub.Copilot --exact

# npm
npm update -g @github/copilot
```

Restart Buzz after upgrading and send a small test mention.

## Troubleshooting

### GitHub Copilot does not appear in Agent runtimes

- Restart Buzz after installing Copilot.
- Run `copilot --version` in the native terminal for the operating system where
  Buzz is running.
- On macOS, check `/opt/homebrew/bin`, `/usr/local/bin`, and `~/.local/bin`.
- On Windows, check `Get-Command copilot` in PowerShell and confirm the result
  is a native executable or npm shim accessible through PATH.
- With Windows Buzz, do not rely on a WSL-only installation.

### Agent logs show `Authentication required`

Run `copilot login` in the same operating-system environment as Buzz, restart
the agent, and resend the request. Confirm that the account has an active
Copilot subscription and that organization policy permits Copilot CLI.

### The agent starts but cannot use tools

Buzz automatically selects ACP's one-time approval option for each requested
tool. Enterprise policy or Copilot sandbox policy may still reject an action.
Review Copilot's policy, trusted-directory, sandbox, and network settings.

### Windows installation succeeds but Buzz still cannot find Copilot

Close every Buzz window and start Buzz again. If npm was used, confirm that
`%APPDATA%\npm` is in the user's PATH. Prefer the WinGet package when possible.

### WSL path or credential problems

Confirm which process is running:

- Windows Buzz requires Windows Copilot credentials and executables.
- Linux Buzz or headless `buzz-acp` inside WSL requires WSL-local credentials
  and executables.

Do not mix the two setups unless you deliberately provide a wrapper at the
boundary and accept the additional quoting, filesystem, and credential risks.

## Security

Managed coding agents can read and modify files and run commands with the
permissions of the account running Buzz. Use trusted repositories, review
changes, keep secrets outside the workspace, and use Copilot's sandbox and
tool restrictions where appropriate.

## References

- [Install GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/install-copilot-cli)
- [Authenticate GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/authenticate-copilot-cli)
- [Copilot CLI ACP server](https://docs.github.com/en/copilot/reference/copilot-cli-reference/acp-server)
- [Buzz ACP harness](../crates/buzz-acp/README.md)
