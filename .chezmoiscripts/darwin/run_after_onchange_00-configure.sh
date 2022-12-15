#!/bin/sh

# ---------------------------------------------------------------------------- #
#                          Unofficial Bash Strict Mode                         #
# ---------------------------------------------------------------------------- #
# See http://redsymbol.net/articles/unofficial-bash-strict-mode/
# -e: exit on error
# -u: exit on unset variables
# -o pipefail: prevents errors in a pipeline from being masked 
set -euo pipefail
# IFS (Internal Field Separator): controls what Bash calls word splitting.
# When set to a string, each character in the string is considered by Bash to separate words
IFS=$'\n\t'

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
