use super::KnownAcpRuntime;

pub(super) const RUNTIME: KnownAcpRuntime = KnownAcpRuntime {
    id: "copilot",
    label: "GitHub Copilot",
    commands: &["copilot"],
    aliases: &[],
    avatar_url: "",
    mcp_command: None,
    mcp_hooks: false,
    underlying_cli: None,
    cli_install_commands: &["curl -fsSL https://gh.io/copilot-install | bash"],
    cli_install_commands_windows: &["powershell.exe -NoProfile -Command \"winget install --id GitHub.Copilot --exact --accept-package-agreements --accept-source-agreements\""],
    adapter_install_commands: &[],
    cli_install_instructions_url: "https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/install-copilot-cli",
    adapter_install_instructions_url: "",
    cli_install_hint: "Buzz talks to GitHub Copilot through the Copilot CLI's native ACP mode. Authenticate it with `copilot login` after installation.",
    adapter_install_hint: "",
    skill_dir: None,
    supports_acp_model_switching: true,
    model_env_var: None,
    provider_env_var: None,
    provider_locked: true,
    default_env: &[],
    config_file_path: Some("~/.copilot/config.json"),
    config_file_format: Some("json"),
    supports_acp_native_config: false,
    thinking_env_var: None,
    max_tokens_env_var: None,
    context_limit_env_var: None,
    max_rounds_env_var: None,
    required_normalized_fields: &[],
    // Copilot has no documented non-interactive login-status command.
    login_hint: None,
    auth_probe_args: None,
};

#[cfg(test)]
mod tests {
    use super::super::normalize_agent_args;
    use super::RUNTIME;

    #[test]
    fn uses_native_acp_stdio_on_mac_and_windows_paths() {
        for command in [
            "/opt/homebrew/bin/copilot",
            r"C:\Program Files\GitHub Copilot\copilot.exe",
        ] {
            assert_eq!(
                normalize_agent_args(command, Vec::new()),
                vec!["--acp", "--stdio"]
            );
        }
    }

    #[test]
    fn uses_official_platform_installers() {
        assert_eq!(
            RUNTIME.cli_install_commands,
            &["curl -fsSL https://gh.io/copilot-install | bash"]
        );
        let windows = RUNTIME.cli_install_commands_windows[0];
        assert!(windows.contains("winget install --id GitHub.Copilot --exact"));
        assert!(windows.contains("--accept-package-agreements"));
        assert!(windows.contains("--accept-source-agreements"));
    }
}
