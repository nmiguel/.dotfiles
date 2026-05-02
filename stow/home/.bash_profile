#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc


function _add_path() {
  local path="$1"
  if [[ -d "$path" && ":$PATH:" != *":$path:"* ]]; then
    export PATH="$path:$PATH"
  fi
}

# Add custom bin directories to PATH
_add_path "$HOME/.local/bin"
_add_path "$HOME/.cargo/bin"
_add_path "$HOME/.config/bin"
_add_path "$HOME/go/bin"

