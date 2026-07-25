# Task completion

- No repository-wide automated test, lint, or build command is defined.
- Always run `git diff --check` on the final change set.
- Validate changed JSON with an available JSON parser and changed plist files with `plutil -lint`.
- For changed shell files, run the repository-appropriate shell syntax check and `shellcheck` when available without changing the intended shell dialect.
- For template or target-state changes, inspect `chezmoi diff`; use `chezmoi apply` only when applying changes to the live home directory is part of the task.
- Finish with `git status --short --branch` to verify the intended staged/committed scope.