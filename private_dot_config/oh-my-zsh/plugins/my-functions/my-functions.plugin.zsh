# Add the functions directory to fpath
# Determines the directory of the plugin using ${0:A:h}. This expression gives the absolute path (:A) of the current script ($0) and then gets its directory (:h).
# FUNCTIONS_DIR="${0:A:h}/functions"
# [[ -d $FUNCTIONS_DIR ]] && fpath=($FUNCTIONS_DIR $fpath)
# echo $fpath

# FIXME: Remove when the fpath works. 🤷

os_brew=$(which brew)

function brew() {
    if [[ $1 == "install" ]] || [[ $1 == "remove" ]]; then
        echo "----- start: brew $1 -----"
        $os_brew "$@"
        echo "----- end: brew $1 -----"

        echo "----- start: brew autoremove -----"
        $os_brew autoremove
        echo "----- end: brew autoremove -----"

        echo "----- start: brew cleanup -----"
        $os_brew autoremove
        echo "----- end: brew cleanup -----"

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

function sillytavern() {
    emulate -L zsh
    zmodload zsh/zutil || return


    # Load the zsh/mapfile module to use the mapfile to list the models

    # Parse the options
    local help model
    zparseopts -D -F -K -- \
        {h,-help}=help \
        {m,-model}=model || return

    local koboldcpp_path="$HOME/Dev/Personal/ai/koboldcpp"
    local models_dir="huggingface"
    local sillytavern_path="$HOME/Dev/Personal/ai/SillyTavern"
    # Presence of options can be checked via (( $#option )).
    if (($#help)); then
        local models_list=$(find "$koboldcpp_path/$models_dir" -mindepth 1 -maxdepth 1 -type f | awk -F/ '{print $NF}' | sort -V)
        print -rC1 -- \
            "$0 [-h|--help]" \
            "$0 [-m|--model] <huggingface model name...>]"
        print ""
        print "Available models:"
        print $models_list
        return
    fi

    local kobold_model="Unholy-v2-13B.i1-Q4_K_M.gguf"
    if (($#model)); then
        print -r -- "model: ${(q+)model[-1]}"
        kobold_model=$model
    fi
    print $kobold_model

    # local launch_sillytavern="$sillytavern_path/launcher.sh &"
    # local launch_koboldcpp="$koboldcpp_path/koboldcpp.py $kobold_model --port 5001 --host 127.0.0.1 &"

    cd $sillytavern_path && ./start.sh &
    cd $koboldcpp_path && ./koboldcpp.py "$models_dir/$kobold_model" --port 5001 --host 127.0.0.1 &
}

# Functions will be loaded on-demand when they are first called, rather than at shell startup
# The -U option prevents alias expansion when loading the function, and the -z option sets the function up for Zsh-style function loading.
autoload -Uz brew git_list_files pip_uninstall
