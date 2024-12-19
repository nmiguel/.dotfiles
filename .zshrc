# zmodload zsh/zprof
# Profiling time

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH

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

# export NVM_LAZY_LOAD=true
# export NVM_COMPLETION=true
# zinit light lukechilds/zsh-nvm


# plugins=(docker docker-compose aliases)
zinit snippet OMZP::docker
zinit snippet OMZP::docker-compose
zinit snippet OMZP::aliases

source $ZSH/oh-my-zsh.sh

bindkey '^H' backward-kill-word

eval "$(zoxide init --cmd cd zsh)"
eval "$(starship init zsh)"

alias v="nvim"
alias docker-compose="docker compose"
alias svenv='source $(fd -up ".*/bin/activate$")'


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

# Profiling time
# zprof
