#!/bin/bash
set -euo pipefail

# Check if Stow exists
if ! command -v stow >/dev/null 2>&1; then
    echo "Error: GNU Stow is not installed. Please install it and re-run the script."
    exit 1
fi

echo "Stowing dotfiles..."
stow -v . -t "$HOME" --ignore '^(README\.md|.*\.sh)$'

# Check for Nix and install it
if ! command -v nix >/dev/null 2>&1; then
    echo "Nix not found. Installing nix..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    # Reload environment variables, adjust path as required
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
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
