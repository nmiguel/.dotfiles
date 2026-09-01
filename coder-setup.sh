#!/usr/bin/env bash
# Bootstrap/refresh the morpheus home-manager configuration on a non-NixOS
# host using nix-portable (rootless nix, shipped in this repo).
#
# What this does:
#   1. Locates nix-portable (PATH, current dir, ~) or installs it into
#      ~/.local/bin.
#   2. Ensures /nix points at nix-portable's virtualized store so that the
#      /nix/store paths home-manager creates resolve on the host and binaries
#      run natively (no proot overhead at runtime).
#   3. Creates the nix profile directories home-manager expects.
#   4. Runs `home-manager switch` for the morpheus configuration via
#      nix-portable, with the nix binary on PATH so the activation script
#      can find it.
#
# Re-run this any time the container/host restarts (the /nix symlink does not
# persist across reboots) or after editing the flake/modules.
set -Eeuo pipefail

on_error() {
  echo "error: command failed (exit $1) at line $2 — aborting" >&2
  exit 1
}
trap 'on_error $? $LINENO' ERR

source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Locate nix-portable: PATH, current dir, ~, otherwise install it into
#    ~/.local/bin.
if command -v nix-portable >/dev/null 2>&1; then
  np="$(command -v nix-portable)"
elif [[ -x ./nix-portable ]]; then
  np="$(pwd)/nix-portable"
elif [[ -x "$HOME/nix-portable" ]]; then
  np="$HOME/nix-portable"
else
  np="$HOME/.local/bin/nix-portable"
  echo "nix-portable not found; installing to $np..."
  mkdir -p "$(dirname "$np")"
  curl -fL "https://github.com/DavHau/nix-portable/releases/latest/download/nix-portable-$(uname -m)" -o "$np"
  chmod +x "$np"
fi
echo "Using nix-portable: $np"

# 2. Make nix-portable's store visible at /nix on the host. nix binaries have
#    /nix/store paths baked into their RPATH/interpreter, so this lets them
#    run natively outside of proot. (A bind mount would be ideal but most
#    containers lack CAP_SYS_ADMIN; a symlink works for execution.)
if [[ ! -e /nix ]]; then
  sudo ln -s "$HOME/.nix-portable/nix" /nix
elif [[ -L /nix ]]; then
  sudo ln -sfn "$HOME/.nix-portable/nix" /nix
fi

# 3. Profile directories home-manager writes into.
mkdir -p /nix/var/nix/profiles/per-user/"$(whoami)" "$HOME/.local/state/nix/profiles"

# 4. Locate the nix binary inside the store so home-manager's activation
#    script (which shells out to `nix`) can find it. nix-portable prints the
#    proot command it runs; we just need the store path.
nix_bindir="$(dirname "$(find /nix/store -maxdepth 3 -type f -executable -name nix 2>/dev/null | sort | tail -n1)")"
if [[ -z "$nix_bindir" ]]; then
  echo "error: could not find nix executable under /nix/store" >&2
  echo "       run '$np nix --version' first to populate the store, then retry." >&2
  exit 1
fi
export PATH="$nix_bindir:$PATH"

echo "Using nix: $nix_bindir/nix"
echo "Running home-manager switch for morpheus..."
exec "$np" nix run home-manager -- switch --flake "$source_dir#morpheus" -b backup
