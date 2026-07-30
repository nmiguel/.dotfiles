#!/usr/bin/env bash
set -euo pipefail

source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

nix_bin="$(find /nix/store -maxdepth 3 -type f -executable -name nix 2>/dev/null | head -n1)"
if [[ -z "$nix_bin" ]]; then
  echo "error: could not find nix executable under /nix/store" >&2
  exit 1
fi

nix_bindir="$(dirname "$nix_bin")"
export PATH="$nix_bindir:$PATH"

mkdir -p /nix/var/nix/profiles/per-user/"$(whoami)" "$HOME/.local/state/nix/profiles"

echo "Using nix: $nix_bin"
exec nix run home-manager -- switch --flake "$source_dir#morpheus" -b backup
