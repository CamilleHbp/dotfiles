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
