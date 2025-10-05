#!/bin/bash

set -euo pipefail

pkg_dir="$(dirname "$0")/packages"
timestamp=$(date +"%Y%m%d_%H%M%S")

# Backup existing package lists if they exist
for pkg_file in pacman aur; do
    if [[ -f "$pkg_dir/$pkg_file" ]]; then
        mv "$pkg_dir/$pkg_file" "$pkg_dir/${pkg_file}_bak_${timestamp}"
    fi
done

# Generate new package lists
# Pacman (repo) packages
pacman -Qqe | grep -v "$(pacman -Qqm)" > "$pkg_dir/pacman"

# AUR packages (foreign)
paru -Qqm > "$pkg_dir/aur"

echo "Package lists updated in $pkg_dir"

