#!/bin/bash

# Check if Stow exists
if ! command -v stow >/dev/null 2>&1; then
    echo "Stow not found. Installing Stow..."
    sudo apt update
    sudo apt install stow
fi

echo "Stowing dotfiles..."
stow --no-folding home -t "$HOME"
