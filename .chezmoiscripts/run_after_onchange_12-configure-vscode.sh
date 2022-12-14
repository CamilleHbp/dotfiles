#!/bin/sh

# ---------------------------------------------------------------------------- #
#                          Unofficial Bash Strict Mode                         #
# ---------------------------------------------------------------------------- #
# See http://redsymbol.net/articles/unofficial-bash-strict-mode/
# -e: exit on error
# -u: exit on unset variables
# -o pipefail: prevents errors in a pipeline from being masked 
set -euo pipefail
# IFS (Internal Field Separator): controls what Bash calls word splitting.
# When set to a string, each character in the string is considered by Bash to separate words
IFS=$'\n\t'

# --------------- Remove press and hold keys conflict on MacOS --------------- #
{{ if eq .chezmoi.os "darwin" -}}
    defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
{{ end -}}

# ---------------------------------------------------------------------------- #
#                           Install VSCode extensions                          #
# ---------------------------------------------------------------------------- #
{{ if eq .chezmoi.os "darwin" "linux" -}}
    {{ $extensions := list
        "aaron-bond.better-comments"
        "alefragnani.project-manager"
        "artdiniz.quitcontrol-vscode"
        "bungcip.better-toml"
        "christian-kohler.npm-intellisense"
        "christian-kohler.path-intellisense"
        "cssho.vscode-svgviewer"
        "davidanson.vscode-markdownlint"
        "dbaeumer.vscode-eslint"
        "dsznajder.es7-react-js-snippets"
        "eamodio.gitlens"
        "ecmel.vscode-html-css"
        "esbenp.prettier-vscode"
        "foxundermoon.shell-format"
        "Gruntfuggly.todo-tree"
        "hediet.vscode-drawio"
        "meganrogge.template-string-converter"
        "mgmcdermott.vscode-language-babel"
        "mikeburgh.xml-format"
        "mikestead.dotenv"
        "ms-azuretools.vscode-docker"
        "ms-python.isort"
        "ms-python.python"
        "ms-vscode-remote.remote-containers"
        "ms-vscode-remote.remote-ssh-edit"
        "ms-vscode-remote.remote-ssh"
        "ms-vscode-remote.vscode-remote-extensionpack"
        "ms-vscode.remote-explorer"
        "ms-vsliveshare.vsliveshare"
        "oouo-diogo-perdigao.docthis"
        "PKief.material-icon-theme"
        "rbbit.typescript-hero"
        "redhat.vscode-yaml"
        "richie5um2.vscode-sort-json"
        "ryuta46.multi-command"
        "shd101wyy.markdown-preview-enhanced"
        "stackbreak.comment-divider"
        "stkb.rewrap"
        "tomoki1207.pdf"
        "Tyriar.sort-lines"
        "vscodevim.vim"
        "wayou.vscode-todo-highlight"
        "yzane.markdown-pdf"
        "yzhang.markdown-all-in-one"
        "zhuangtongfa.material-theme"
    -}}

    {{ range $extensions -}}
        code --force --install-extension {{ . }}
    {{ end -}}
{{ end -}}
