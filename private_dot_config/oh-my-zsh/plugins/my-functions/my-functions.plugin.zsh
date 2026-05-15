# Add the functions directory to fpath
# Determines the directory of the plugin using ${0:A:h}. This expression gives the absolute path (:A) of the current script ($0) and then gets its directory (:h).
# FUNCTIONS_DIR="${0:A:h}/functions"
# [[ -d $FUNCTIONS_DIR ]] && fpath=($FUNCTIONS_DIR $fpath)
# echo $fpath

# FIXME: Remove when the fpath works. 🤷

# Wrapper around brew to perform additional maintenance tasks after certain actions
# Specifically, after installing, removing, uninstalling, upgrading, or reinstalling packages, it runs `brew autoremove` and `brew cleanup`, regenerates the Brewfile, and adds it to chezmoi if available.
function brew() {
    local brew_action=$1
    if [[ $brew_action == "install" ]] || [[ $brew_action == "remove" ]] || [[ $brew_action == "uninstall" ]] || [[ $brew_action == "upgrade" ]] || [[ $brew_action == "reinstall" ]]; then
        echo "----- start: brew $brew_action -----"
        command brew "$@"
        echo "----- end: brew $brew_action -----"

        echo "----- start: brew autoremove -----"
        command brew autoremove
        echo "----- end: brew autoremove -----"

        echo "----- start: brew cleanup -----"
        command brew cleanup
        echo "----- end: brew cleanup -----"

        echo "----- start: Generate Brewfile -----"
        local brewfile_path
        brewfile_path=${HOMEBREW_BUNDLE_FILE:-"$HOME/.config/homebrew/Brewfile"}
        command brew bundle dump --force --describe --file "$brewfile_path"
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
        command brew "$@"
    fi
}

# Git: List the largest files in the git repository along with their paths
function git_list_files() {
    while read -r largefile; do
        echo $largefile | awk '{printf "%s %s ", $1, $3 ; system("git rev-list --all --objects | grep " $1 " | cut -d \" \" -f 2-")}'
    done <<<"$(git rev-list --all --objects | awk '{print $1}' | git cat-file --batch-check | sort -k3nr | head -n 20)"
}

# Git: Delete local branches whose upstream no longer exists on the remote.
# - Merged branches are deleted without confirmation.
# - Unmerged branches require confirmation.
function git_delete() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
        echo "Not inside a git repository."
        return 1
    }

    local current_branch base_branch
    current_branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null)

    echo "Pruning remotes (git fetch --prune --all --prune-tags)..."
    git fetch --prune --all --prune-tags || return $?

    # Prefer origin's default branch as the merge target.
    base_branch=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@')
    if [[ -z $base_branch ]]; then
        local candidate
        for candidate in trunk main master; do
            if git show-ref --verify --quiet "refs/heads/${candidate}"; then
                base_branch=$candidate
                break
            fi
        done
    fi
    [[ -z $base_branch ]] && base_branch=${current_branch:-HEAD}

    local -a gone_branches
    local branch track
    while IFS=$'\t' read -r branch track; do
        [[ $track == "gone" ]] || continue
        [[ -n $current_branch && $branch == "$current_branch" ]] && continue
        gone_branches+=("$branch")
    done < <(git for-each-ref --format=$'%(refname:short)\t%(upstream:track,nobracket)' refs/heads)

    if (( ${#gone_branches[@]} == 0 )); then
        echo "No local branches with gone upstreams."
        return 0
    fi

    echo "Found ${#gone_branches[@]} local branch(es) whose upstream is gone:"
    printf '  %s\n' "${gone_branches[@]}"
    echo "Merge target: ${base_branch}"

    for branch in "${gone_branches[@]}"; do
        # Treat as merged if its tip is reachable from base_branch (or current HEAD as a fallback).
        if git merge-base --is-ancestor "$branch" "$base_branch" 2>/dev/null || git merge-base --is-ancestor "$branch" HEAD 2>/dev/null; then
            echo "Deleting merged branch: $branch"
            git branch -d -- "$branch"
            continue
        fi

        # Squash-merges/cherry-picks don't preserve ancestry, so the check above can be false even
        # when the branch's changes are already integrated. Detect that case by asking Git what
        # tree would result from merging the branch into the base; if it equals the base tree and
        # the merge is clean, the branch introduces no net changes.
        local base_commit branch_commit base_tree merge_tree
        base_commit=$(git rev-parse --verify "$base_branch" 2>/dev/null)
        branch_commit=$(git rev-parse --verify "$branch" 2>/dev/null)
        base_tree=$(git rev-parse "${base_commit}^{tree}" 2>/dev/null)
        merge_tree=$(git merge-tree --write-tree "$base_commit" "$branch_commit" 2>/dev/null)
        if [[ $? -eq 0 ]]; then
            merge_tree=${merge_tree%%$'\n'*}
            if [[ -n $base_tree && $merge_tree == $base_tree ]]; then
                echo "Deleting integrated branch (squash/cherry-pick): $branch"
                git branch -D -- "$branch"
                continue
            fi
        fi

        if read -q "REPLY?Delete unmerged branch '$branch'? [y/N] "; then
            print
            git branch -D -- "$branch"
        else
            print
            echo "Skipping: $branch"
        fi
    done
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
# Upgrade Headroom and restart the persistent proxy service.
function headroom_upgrade_restart() {
  emulate -L zsh
  set -e

  local profile="${1:-default}"
  local port="${HEADROOM_PORT:-8787}"
  local uid plist label

  uv tool install --upgrade --force 'headroom-ai[all]'
  headroom tools install

  if ! headroom install restart --profile "$profile"; then
    local -a pids
    local pid command

    pids=("${(@f)$(lsof -tiTCP:"$port" -sTCP:LISTEN 2>/dev/null || true)}")
    for pid in "${pids[@]}"; do
      command=$(ps -p "$pid" -o command= 2>/dev/null || true)
      if [[ "$command" == *"headroom.cli proxy"* ]]; then
        kill "$pid" 2>/dev/null || true
      fi
    done

    uid=$(id -u)
    label="com.headroom.${profile}"
    plist="$HOME/Library/LaunchAgents/${label}.plist"
    launchctl bootout "gui/${uid}/${label}" >/dev/null 2>&1 || true
    launchctl bootstrap "gui/${uid}" "$plist" 2>/dev/null || true
    launchctl kickstart -k "gui/${uid}/${label}" 2>/dev/null || true
  fi

  headroom install status --profile "$profile"
}

autoload -Uz git_list_files pip_uninstall
