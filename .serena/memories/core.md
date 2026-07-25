# Project core

- Personal dotfiles source state managed by chezmoi; bootstrap command is documented in `README.md`, with a repository-local `install.sh` for one-shot application.
- Root `.chezmoi*` files control target data, exclusions, externals, and lifecycle scripts.
- Chezmoi source-state names (`dot_*`, `private_*`, `executable_*`, `symlink_*.tmpl`) map repository files to target home-directory paths.
- `darwin/` stores macOS application configuration snapshots; matching templates under `private_Library/` and `private_dot_config/` symlink target application paths to those snapshots.
- Read `mem:tech_stack` for configuration formats and tooling, `mem:conventions` for source-state layout rules, `mem:suggested_commands` for repository workflows, and `mem:task_completion` for validation expectations.