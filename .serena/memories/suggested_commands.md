# Suggested commands

- Bootstrap this source state: `./install.sh` (supports forwarding chezmoi arguments and environment-controlled one-shot/debug modes).
- Preview target changes: `chezmoi diff`.
- Apply managed state: `chezmoi apply`.
- Capture a live file into the source state: `chezmoi add <target-path>`; the custom Homebrew helper uses this after regenerating the Brewfile.
- Inspect changes before commit: `git status --short --branch`, `git diff`, and `git diff --cached`.
- Serena memory-reference audit from the project root: `serena memories check`.