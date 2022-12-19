#!/bin/sh

#### Unofficial Bash Strict Mode ###
# See http://redsymbol.net/articles/unofficial-bash-strict-mode/

# -e: exit on error
# -u: exit on unset variables
# -o pipefail: prevents errors in a pipeline from being masked 
set -euo pipefail
# IFS (Internal Field Separator): controls what Bash calls word splitting.
# When set to a string, each character in the string is considered by Bash to separate words
IFS=$'\n\t'

log_color() {
  color_code="$1"
  shift

  printf "\033[${color_code}m%s\033[0m\n" "$*" >&2
}

log_red() {
  log_color "0;31" "$@"
}

log_blue() {
  log_color "0;34" "$@"
}

log_task() {
  log_blue "🔃" "$@"
}

log_error() {
  log_red "❌" "$@"
}

error() {
  log_error "$@"
  exit 1
}

if ! chezmoi="$(command -v chezmoi)"; then
  bin_dir="${HOME}/.local/bin"
  chezmoi="${bin_dir}/chezmoi"
  log_task "Installing chezmoi to '${chezmoi}'"
  if command -v curl >/dev/null; then
    chezmoi_install_script="$(curl -fsSL https://get.chezmoi.io)"
    # TODO: look into checking signature with SHASUM and cosign
  elif command -v wget >/dev/null; then
    chezmoi_install_script="$(wget -qO- https://get.chezmoi.io)"
  else
    error "To install chezmoi, you must have curl or wget."
  fi
  sh -c "${chezmoi_install_script}" -- -b "${bin_dir}"
  unset chezmoi_install_script bin_dir
fi

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
# shellcheck disable=SC2312
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

# Use a prompt to ask if init should be run or not
set -- init --source="${script_dir}"

# --one-shot is the equivalent of --apply, --depth=1, --force, --purge, and --purge-binary.
# It attempts to install your dotfiles with chezmoi and then remove all traces of chezmoi from the system.
# This is useful for setting up temporary environments (e.g. Docker containers).
if [ -n "${DOTFILES_ONE_SHOT-}" ]; then
  set -- "$@" --one-shot
else
  set -- "$@" --apply CamilleHbp
fi

# The --debug flag makes chezmoi print very detailed step by step information.
if [ -n "${DOTFILES_DEBUG-}" ]; then
  set -- "$@" --debug
fi

log_task "Running 'chezmoi $*'"
# replace current process with chezmoi
exec "${chezmoi}" "$@"
