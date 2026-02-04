# Add the functions directory to fpath
# Determines the directory of the plugin using ${0:A:h}. This expression gives the absolute path (:A) of the current script ($0) and then gets its directory (:h).
# FUNCTIONS_DIR="${0:A:h}/functions"
# [[ -d $FUNCTIONS_DIR ]] && fpath=($FUNCTIONS_DIR $fpath)
# echo $fpath

# FIXME: Remove when the fpath works. 🤷

os_brew=$(which brew)

# Wrapper around brew to perform additional maintenance tasks after certain actions
# Specifically, after installing, removing, uninstalling, upgrading, or reinstalling packages, it runs `brew autoremove` and `brew cleanup`, regenerates the Brewfile, and adds it to chezmoi if available.
function brew() {
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

# Git: List the largest files in the git repository along with their paths
function git_list_files() {
    while read -r largefile; do
        echo $largefile | awk '{printf "%s %s ", $1, $3 ; system("git rev-list --all --objects | grep " $1 " | cut -d \" \" -f 2-")}'
    done <<<"$(git rev-list --all --objects | awk '{print $1}' | git cat-file --batch-check | sort -k3nr | head -n 20)"
}

# [nnn: terminal file manager](https://github.com/jarun/nnn)
# This function wraps the nnn terminal file manager to enable changing the current shell directory upon exiting nnn.
function n () {
    # Block nesting of nnn in subshells
    [ "${NNNLVL:-0}" -eq 0 ] || {
        echo "nnn is already running"
        return
    }

    # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
    # If NNN_TMPFILE is set to a custom path, it must be exported for nnn to
    # see. To cd on quit only on ^G, remove the "export" and make sure not to
    # use a custom path, i.e. set NNN_TMPFILE *exactly* as follows:
    #      NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef

    # The command builtin allows one to alias nnn to n, if desired, without
    # making an infinitely recursive alias
    command nnn "$@"

    [ ! -f "$NNN_TMPFILE" ] || {
        . "$NNN_TMPFILE"
        rm -f -- "$NNN_TMPFILE" > /dev/null
    }
}

# Functions will be loaded on-demand when they are first called, rather than at shell startup
# The -U option prevents alias expansion when loading the function, and the -z option sets the function up for Zsh-style function loading.
autoload -Uz git_list_files pip_uninstall
