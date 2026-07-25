# Tech stack

- Chezmoi is the primary configuration manager; Go-template files use the `.tmpl` suffix and `.chezmoi` data.
- Shell automation is split between POSIX-style bootstrap/lifecycle scripts and interactive Zsh configuration/plugins.
- macOS packages are declared in `private_dot_config/homebrew/Brewfile`.
- Managed artifacts include JSON, plist, INI, SQLite-like application exports, SSH/Git configuration, editor settings, and application-specific text formats.
- macOS is a first-class target; templates use `.chezmoi.os`, `.chezmoi.arch`, host identity, and personal/headless/ephemeral flags for conditional behavior.
- This is a configuration repository, not a single compiled application; no repository-wide package manifest or build system is present.