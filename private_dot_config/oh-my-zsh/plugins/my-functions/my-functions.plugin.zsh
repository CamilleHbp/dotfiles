# Add the functions directory to fpath
# Determines the directory of the plugin using ${0:A:h}. This expression gives the absolute path (:A) of the current script ($0) and then gets its directory (:h).
# FUNCTIONS_DIR="${0:A:h}/functions"
# [[ -d $FUNCTIONS_DIR ]] && fpath=($FUNCTIONS_DIR $fpath)
# echo $fpath

# FIXME: Remove when the fpath works. 🤷

os_brew=$(which brew)

function brew() {
    if [[ $1 == "install" ]]; then
        echo "----- start: brew install -----"
        $os_brew "$@"
        echo "----- end: brew install -----"

        echo "----- start: brew autoremove -----"
        $os_brew autoremove
        echo "----- end: brew autoremove -----"

        echo "----- start: Generate Brewfile -----"
        if [[ -n $HOMEBREW_BUNDLE_FILE ]]; then
            $os_brew bundle dump --force --describe
        else
            echo "Impossible to generate Brewfile, HOMEBREW_BUNDLE_FILE isn't set"
        fi
        echo "----- end: Generate Brewfile -----"
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
autoload -Uz brew git_list_files pip_uninstall
