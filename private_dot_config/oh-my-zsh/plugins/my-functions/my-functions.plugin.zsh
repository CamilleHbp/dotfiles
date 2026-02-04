# Add the functions directory to fpath
# Determines the directory of the plugin using ${0:A:h}. This expression gives the absolute path (:A) of the current script ($0) and then gets its directory (:h).
# FUNCTIONS_DIR="${0:A:h}/functions"
# [[ -d $FUNCTIONS_DIR ]] && fpath=($FUNCTIONS_DIR $fpath)
# echo $fpath

# FIXME: Remove when the fpath works. 🤷

os_brew=$(which brew)

brew() {
    local brew_action=$1
    if [[ $brew_action == "install" ]] || [[ $brew_action == "remove" ]] || [[ $brew_action == "uninstall" ]] || [[ $brew_action == "upgrade" ]] || [[ $brew_action == "reinstall" ]]; then
        echo "----- start: brew $brew_action -----"
        $os_brew "$@"
        echo "----- end: brew $brew_action -----"

        echo "----- start: brew autoremove -----"
        $os_brew autoremove
        echo "----- end: brew autoremove -----"

        echo "----- start: brew cleanup -----"
        $os_brew cleanup
        echo "----- end: brew cleanup -----"

        echo "----- start: Generate Brewfile -----"
        local brewfile_path
        brewfile_path=${HOMEBREW_BUNDLE_FILE:-"$HOME/.config/homebrew/Brewfile"}
        $os_brew bundle dump --force --describe --file "$brewfile_path"
        echo "----- end: Generate Brewfile -----"

        echo "----- start: Add Brewfile to chezmoi -----"
        if command -v chezmoi >/dev/null 2>&1; then
            if chezmoi add "$brewfile_path" 2>&1; then
                echo "Successfully added $brewfile_path to chezmoi"
            else
                echo "Error: Failed to add $brewfile_path to chezmoi" >&2
            fi
        else
            echo "chezmoi isn't available in PATH; skipping 'chezmoi add'"
        fi
        echo "----- end: Add Brewfile to chezmoi -----"
    else
        $os_brew "$@"
    fi
}

function git_list_files() {
    while read -r largefile; do
        echo $largefile | awk '{printf "%s %s ", $1, $3 ; system("git rev-list --all --objects | grep " $1 " | cut -d \" \" -f 2-")}'
    done <<<"$(git rev-list --all --objects | awk '{print $1}' | git cat-file --batch-check | sort -k3nr | head -n 20)"
}

function pip_uninstall() {
    pip install -q pipdeptree
    pipdeptree -p$1 -fj | jq ".[] | .package.key" | xargs pip uninstall -y
}

# Functions will be loaded on-demand when they are first called, rather than at shell startup
# The -U option prevents alias expansion when loading the function, and the -z option sets the function up for Zsh-style function loading.
autoload -Uz git_list_files pip_uninstall
