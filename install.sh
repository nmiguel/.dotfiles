#!/bin/bash

set -euo pipefail


# Check if Stow exists
if ! command -v stow >/dev/null 2>&1; then
    echo "Stow not found. Installing Stow..."
    sudo apt update
    apt install stow
fi

echo "Stowing dotfiles..."
stow --no-folding . -t "$HOME"  --ignore '^(README\.md|.*\.sh)$'

# Check for Nix and install it
if ! command -v nix >/dev/null 2>&1; then
    echo "Nix not found. Installing as root..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sudo sh -s -- install
    # Source nix profile in current shell
    if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi
else
    echo "Nix already installed, skipping installation."
fi

echo "Syncing Home-Manager"
nix run nixpkgs#home-manager -- switch --flake ./.config/nix#$USER

# Install TPM
tpm_dir="$HOME/.tmux/plugins/tpm"
if [ ! -d "$tpm_dir" ]; then
    echo "TMUX TPM not found. Cloning into $tpm_dir ..."
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
else
    echo "TMUX TPM already exists; skipping clone."
fi
