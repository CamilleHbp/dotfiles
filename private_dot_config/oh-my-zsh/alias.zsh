# ---------------------------------- Aliases --------------------------------- #
# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
alias appsupport="cd ~/Library/Application\ Support"
alias invoke="invokeai && source .venv/bin/activate"
alias spotx='bash <(curl -sSL https://raw.githubusercontent.com/Nuzair46/BlockTheSpot-Mac/main/install.sh) -u'
# alias spotx-mac='bash <(curl -sSL https://raw.githubusercontent.com/SpotX-CLI/SpotX-Mac/main/install.sh)'
# alias spotx='bash <(curl -sSL https://spotx-official.github.io/run.sh) -c -B --installmac'
alias vi=nvim
alias vim=nvim

# --------------------------------- Projects --------------------------------- #
alias dev='cd ~/Dev/Personal'
alias retro='dev && cd retro-music-player'
alias fiction='dev && cd fiction-live-search'
alias questforge='dev && cd questforge'
alias questforge-core='questforge && cd ./questforge-core'
alias questforge-web='questforge && cd ./questforge-web'

# -------------------------------- AI project -------------------------------- #
alias ai="dev && cd ai"

# ---------------------------- Nos Futurs projects --------------------------- #
alias nf='cd ~/Dev/NosFuturs'
alias nf-clients='nf && cd ./clients'
alias nf-internal='nf && cd ./internal'
alias nf-templates='nf && cd ./templates'
alias nf-argo='nf-internal && cd ./main-cluster-argocd'
alias zeus='nf && cd ./clients/zeus-v4'
alias zeus-core='zeus && cd ./zeus-core'
alias zeus-web='zeus && cd ./zeus-web'
alias zeus-types='zeus && cd ./zeus-types'

# ------------------------------- Work projects ------------------------------ #
alias boussole='cd ~/Dev/boussole'
alias boussole-app='boussole && cd ./boussole-app'
alias boussole-front='boussole && cd ./boussole-front'
alias boussole-engine='boussole && cd ./boussole-impact-engine'
