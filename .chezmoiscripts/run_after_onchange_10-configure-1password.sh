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
#                        Add 1Password acount and signin                       #
# ---------------------------------------------------------------------------- #
# This command can be used with arguments, but we need to figure out how to add them securely (github secrets?)
op account add
eval $(op signin)

