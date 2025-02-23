# zmodload zsh/zprof
# Profiling time

export PATH=$HOME/.local/bin:$HOME/.local/scripts:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"



# plugins=(docker docker-compose aliases)
zinit snippet OMZP::docker
zinit snippet OMZP::docker-compose
zinit snippet OMZP::aliases

zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting

source $ZSH/oh-my-zsh.sh

bindkey '^H' backward-kill-word
bindkey '^Y' autosuggest-accept
bindkey '^J' autosuggest-accept

eval "$(zoxide init --cmd cd zsh)"
eval "$(starship init zsh)"

alias v="nvim"
alias docker-compose="docker compose"

# Custom commands
alias svenv='source $(fd -up ".*/bin/activate$")'

function newnote() {
    cd ~/projects/personal/notes
    note_path="$1"
    if [[ -n "$note_path" ]]; then
        nvim "$note_path".md
    else
        nvim .
    fi
    cd -1 >/dev/null 2>&1
}

function notes() {
    cd ~/projects/personal/notes
    selection="$(tv text)"
    if [[ -n "$selection" ]]; then
        file="$(echo "$selection" | cut -d: -f1)"
        line="$(echo "$selection" | cut -d: -f2)"
        [[ -z "$line" ]] && line=1
        nvim +"$line" "$file"
    fi
    cd -1 >/dev/null 2>&1
}



export EDITOR=nvim

# dotnet
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools#

# Go
export GOBIN=$GOPATH/bin
export GOROOT=/usr/local/go
export GOPATH=$HOME/.go
export PATH=$PATH:/usr/local/go/bin


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH=$PATH:/mnt/c/Windows:/mnt/c/Windows/System32:/mnt/c/Windows/System32/wbem:/mnt/c/Windows/System32/Win:/mnt/c/Windows/System32/WindowsPowerShell/v1.0

eval "$(tv init zsh)"

# Profiling time
# zprof
