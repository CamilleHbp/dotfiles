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
# Reinstall Headroom from the local checkout and restart persistent proxy service.
function headroom_upgrade_restart() {
  emulate -L zsh
  # NOTE: do NOT use `set -e` here — ERR_EXIT kills the interactive shell session
  # (closing the terminal) whenever any command returns non-zero, because `exit`
  # is called before `emulate -L zsh` can restore the option on function return.

  local profile="${1:-default}"
  local port="${HEADROOM_PORT:-8787}"
  local repo="${HEADROOM_REPO:-/Users/camille/Dev/Personal/headroom}"
  local extras="${HEADROOM_EXTRAS:-proxy}"
  local health_timeout="${HEADROOM_HEALTH_TIMEOUT:-30}"
  local health_url="${HEADROOM_HEALTH_URL:-http://127.0.0.1:${port}/readyz}"
  local log_file="${HEADROOM_WORKSPACE_DIR:-$HOME/.headroom}/deploy/${profile}/runner.log"
  local uid plist label

  if [[ ! -f "$repo/pyproject.toml" ]]; then
    print -u2 "headroom repo not found: $repo"
    return 1
  fi

  print "==> Installing Headroom from $repo [${extras}]"
  uv tool install --force --editable "${repo}[${extras}]" || return $?

  print "==> Installing Headroom tool binaries"
  headroom tools install || return $?

  print "==> Restarting Headroom deployment '$profile'"
  if ! headroom install restart --profile "$profile"; then
    local -a pids
    local pid command

    pids=("${(@f)$(lsof -tiTCP:"$port" -sTCP:LISTEN 2>/dev/null || true)}")
    for pid in "${pids[@]}"; do
      command=$(ps -p "$pid" -o command= 2>/dev/null || true)
      if [[ "$command" == *"headroom.cli proxy"* || "$command" == *"headroom proxy"* ]]; then
        kill "$pid" 2>/dev/null || true
      fi
    done

    uid=$(id -u)
    label="com.headroom.${profile}"
    plist="$HOME/Library/LaunchAgents/${label}.plist"
    if [[ ! -f "$plist" ]]; then
      print -u2 "LaunchAgent not found: $plist"
      print -u2 "Try: headroom install apply --preset persistent-service --profile $profile"
      return 1
    fi
    launchctl bootout "gui/${uid}/${label}" >/dev/null 2>&1 || true
    launchctl bootstrap "gui/${uid}" "$plist"
    launchctl kickstart -k "gui/${uid}/${label}" 2>/dev/null || true
  fi

  print "==> Active Headroom version"
  headroom --version || return $?
  _headroom_wait_healthy "$health_url" "$health_timeout" "$log_file" || return $?

  print "==> Deployment status"
  headroom install status --profile "$profile"
}

# Stop and remove a persistent Headroom deployment without reinstalling anything.
function headroom_off() {
  emulate -L zsh
  set -e

  local profile="${1:-default}"
  local port="${HEADROOM_PORT:-8787}"
  local uid label plist

  uid="$(id -u)"
  label="com.headroom.${profile}"
  plist="$HOME/Library/LaunchAgents/${label}.plist"

  print "==> Switching off Headroom deployment '$profile'"

  if command -v headroom >/dev/null 2>&1; then
    if headroom install status --profile "$profile" >/dev/null 2>&1; then
      print "==> Removing Headroom persistent deployment"
      headroom install remove --profile "$profile"
    elif headroom status --profile "$profile" >/dev/null 2>&1; then
      print "==> Removing Headroom persistent deployment"
      headroom remove --profile "$profile"
    else
      print "==> No Headroom deployment manifest found for '$profile'"
    fi
  else
    print "==> headroom command not found; using launchd/port cleanup fallback"
  fi

  if [[ -f "$plist" ]]; then
    print "==> Unloading LaunchAgent $label"
    launchctl bootout "gui/${uid}/${label}" >/dev/null 2>&1 || true
    rm -f -- "$plist"
  fi

  local -a pids
  local pid command
  pids=("${(@f)$(lsof -tiTCP:"$port" -sTCP:LISTEN 2>/dev/null || true)}")
  for pid in "${pids[@]}"; do
    command="$(ps -p "$pid" -o command= 2>/dev/null || true)"
    if [[ "$command" == *"headroom.cli proxy"* || "$command" == *"headroom proxy"* ]]; then
      print "==> Stopping leftover Headroom listener on port ${port} (pid ${pid})"
      kill "$pid" 2>/dev/null || true
    fi
  done

  print "==> Headroom is switched off for profile '$profile'"
  print "    To re-enable later: headroom_upgrade_restart ${profile}"
}

function _headroom_wait_healthy() {
  emulate -L zsh

  local health_url="$1"
  local timeout="${2:-45}"
  local log_file="${3:-}"
  local started="$SECONDS"
  local body
  local frames=('|' '/' '-' '\')
  local frame_index=1
  local elapsed=0
  local next_report=0

  printf "==> Waiting for Headroom health (%ss timeout): %s\n" "$timeout" "$health_url"
  while (( elapsed < timeout )); do
    body="$(curl -fsS --connect-timeout 1 --max-time 1 "$health_url" 2>/dev/null || true)"
    elapsed=$(( SECONDS - started ))
    if [[ "$body" == *'"ready":true'* || "$body" == *'"ready": true'* || "$body" == *'"status":"healthy"'* || "$body" == *'"status": "healthy"'* ]]; then
      printf "==> Headroom is healthy after %ss.\n" "$elapsed"
      return 0
    fi

    if (( elapsed >= next_report )); then
      printf "    %s waiting for healthy response... %ss/%ss\n" "$frames[$frame_index]" "$elapsed" "$timeout"
      frame_index=$(( frame_index % ${#frames[@]} + 1 ))
      next_report=$(( elapsed + 3 ))
    fi
    (( elapsed < timeout )) && sleep 1
  done

  print -u2 "ERROR: Headroom did not report healthy within ${timeout}s."
  print -u2 "Health URL: ${health_url}"
  if [[ -n "$log_file" ]]; then
    print -u2 "Log file: ${log_file}"
    print -u2 "Try: tail -n 80 ${log_file}"
  fi
  return 1
}

autoload -Uz git_list_files pip_uninstall
