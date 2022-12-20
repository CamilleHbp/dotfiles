#!/bin/sh

# ---------------------------------------------------------------------------- #
#                          Unofficial Bash Strict Mode                         #
# ---------------------------------------------------------------------------- #
# See http://redsymbol.net/articles/unofficial-bash-strict-mode/
# -e: exit on error
# -u: exit on unset variables
# -o pipefail: prevents errors in a pipeline from being masked 
set -eu pipefail
# IFS (Internal Field Separator): controls what Bash calls word splitting.
# When set to a string, each character in the string is considered by Bash to separate words
IFS=$'\n\t'

# ---------------------------------------------------------------------------- #
#                                     Logs                                     #
# ---------------------------------------------------------------------------- #
log_color() {
    wait
    color_code="$1"
    shift
    printf "\033[${color_code}m%s\033[0m\n" "$*" >&2
}
# -------------------------------- Log colours ------------------------------- #
log_blue() { log_color "0;34" "$@" ; }
log_green() { log_color "0;32" "$@" ; }
log_orange() { log_color "0;33" "$@" ; }
log_red() { log_color "0;31" "$@" ; }
# --------------------------------- Log state -------------------------------- #
log_error() { log_red "❌ $@" ; }
log_success() { log_green "✅ $@" ; }
log_task() { log_blue "🔃 $@" ; }
log_warning() { log_orange "⚠️ $@" ; }
# ---------------------------- Log exit functions ---------------------------- #
error() { log_error "$@" ; exit 1 ; }
success() { log_success "$@" ; exit 0 ; }

# ---------------------------------------------------------------------------- #
#                                    Script                                    #
# ---------------------------------------------------------------------------- #
log_task "[Macos] SETUP"

# ---------------------------------------------------------------------------- #
#                                  Apple MacOS                                 #
# ---------------------------------------------------------------------------- #
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# ---------------------------------------------------------------------------- #
#                               Apple MacOS Dock                               #
# ---------------------------------------------------------------------------- #
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
defaults write com.apple.dock show-recents -bool false

# ---------------------------------------------------------------------------- #
#                                    iTerm2                                    #
# ---------------------------------------------------------------------------- #
# Load iTerm2 settings from the dotfiles folder
defaults write com.googlecode.iterm2 "PrefsCustomFolder" -string "~/.config/iterm2"
defaults write com.googlecode.iterm2 "LoadPrefsFromCustomFolder" -bool true

# ---------------------------------------------------------------------------- #
#                                    VSCode                                    #
# ---------------------------------------------------------------------------- #
# Remove press and hold keys conflict on MacOS
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

log_success "[Macos] DONE"
