#!/bin/bash

# Install TPM
tpm_dir="$HOME/.tmux/plugins/tpm"
if [ ! -d "$tpm_dir" ]; then
    echo "TMUX TPM not found. Cloning into $tpm_dir ..."
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
else
    echo "TMUX TPM already exists; skipping clone."
fi
