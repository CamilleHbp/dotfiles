# ---------------------------------- Aliases --------------------------------- #
# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
alias invoke="invokeai && source .venv/bin/activate"
alias spotx-mac='bash <(curl -sSL https://raw.githubusercontent.com/SpotX-CLI/SpotX-Mac/main/install.sh)'
alias spotx='bash <(curl -sSL https://spotx-official.github.io/run.sh) -c -B --installmac'
alias vi=nvim
alias vim=nvim

# --------------------------------- Corepack --------------------------------- #
alias yarn="corepack yarn"
alias yarnpkg="corepack yarnpkg"
alias pnpm="corepack pnpm"
alias pnpx="corepack pnpm dlx"
alias npm="corepack npm"
alias npx="corepack npx"

# --------------------------------- Projects --------------------------------- #
alias dev='cd ~/Dev/Personal'
alias invokeai="dev && cd InvokeAI"
alias nf='cd ~/Dev/NosFuturs'
alias nf-clients='nf && cd ./clients'
alias nf-internal='nf && cd ./internal'
alias nf-templates='nf && cd ./templates'
alias renpy='personal && cd "Renpy Projects"'
