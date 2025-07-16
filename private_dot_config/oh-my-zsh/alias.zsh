# ---------------------------------- Aliases --------------------------------- #
# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
alias invoke="invokeai && source .venv/bin/activate"
alias spotx='bash <(curl -sSL https://raw.githubusercontent.com/Nuzair46/BlockTheSpot-Mac/main/install.sh) -u'
# alias spotx-mac='bash <(curl -sSL https://raw.githubusercontent.com/SpotX-CLI/SpotX-Mac/main/install.sh)'
# alias spotx='bash <(curl -sSL https://spotx-official.github.io/run.sh) -c -B --installmac'
alias vi=nvim
alias vim=nvim

# --------------------------------- Corepack --------------------------------- #
alias yarn="corepack yarn"
alias yarnpkg="corepack yarnpkg"
alias pnpm="corepack pnpm"
alias pnpx="corepack pnpm dlx"

# --------------------------------- Projects --------------------------------- #
alias anytype="dev && cd anytype-ts"
alias dev='cd ~/Dev/Personal'
alias renpy='personal && cd "Renpy Projects"'

# -------------------------------- AI project -------------------------------- #
alias ai="dev && cd ai"
alias novelaize='dev && cd novelaize'
alias rag="ai && cd rag"

# ---------------------------- Nos Futurs projects --------------------------- #
alias nf='cd ~/Dev/NosFuturs'
alias nf-clients='nf && cd ./clients'
alias nf-internal='nf && cd ./internal'
alias nf-templates='nf && cd ./templates'
alias nf-zeus='nf && cd ./clients/zeus'

# ------------------------------- Work projects ------------------------------ #
alias boussole='cd ~/Dev/boussole'
alias boussole-app='boussole && cd ./boussole-app'
alias boussole-front='boussole && cd ./boussole-front'
alias boussole-engine='boussole && cd ./boussole-impact-engine'