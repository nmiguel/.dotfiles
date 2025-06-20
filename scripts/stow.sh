#!/bin/bash

# Check if Stow exists
if ! command -v stow >/dev/null 2>&1; then
    echo "Stow not found. Installing Stow..."
    sudo apt update
    sudo apt install stow
fi

echo "Stowing dotfiles..."

cd stow
stow config -t "$HOME/.config" -v
stow home -t "$HOME" -v

# for each folder or file in the home/ directory stow it
# for dir in */; do
#     echo "Stowing $dir..."
#       pkg="${pkg%/}"                      # strip trailing slash
#       stow -n "$CONFIG_DIR" -t "$HOME/.config" "$pkg" -v
# done
