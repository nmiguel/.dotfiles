#!/usr/bin/env bash
# Install standard Nix and enable the CLI features required by this flake.
set -Eeuo pipefail

usage() {
  cat <<'EOF'
Usage: bootstrap-nix.sh

Installs the official multi-user Nix distribution and enables nix-command and
flakes.
EOF
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

if (($# > 0)); then
  usage >&2
  exit 2
fi

load_nix_profile() {
  local profile

  for profile in \
    "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" \
    "$HOME/.nix-profile/etc/profile.d/nix.sh"; do
    if [[ -r $profile ]]; then
      set +u
      # shellcheck disable=SC1090
      source "$profile"
      set -u
    fi
  done

  export PATH="/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:$PATH"
  hash -r
}

configure_nix() {
  local config_dir="$HOME/.config/nix"
  local config_file="$config_dir/nix.conf"

  mkdir -p "$config_dir"
  touch "$config_file"

  if ! grep -Eq '^[[:space:]]*(extra-)?experimental-features[[:space:]]*=.*nix-command' "$config_file" ||
    ! grep -Eq '^[[:space:]]*(extra-)?experimental-features[[:space:]]*=.*flakes' "$config_file"; then
    if [[ -s $config_file ]]; then
      printf '\n' >>"$config_file"
    fi
    printf 'extra-experimental-features = nix-command flakes\n' >>"$config_file"
  fi
}

if ! command -v nix >/dev/null 2>&1; then
  if ! command -v curl >/dev/null 2>&1; then
    printf 'error: curl is required to install Nix\n' >&2
    exit 1
  fi

  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' EXIT
  installer="$temp_dir/install-nix"

  printf 'Downloading the official Nix installer...\n'
  curl --proto '=https' --tlsv1.2 --fail --location --retry 3 \
    https://nixos.org/nix/install --output "$installer"

  printf 'Installing Nix in multi-user mode...\n'
  sh "$installer" --daemon
  load_nix_profile
else
  printf 'Nix is already installed at %s\n' "$(command -v nix)"
fi

configure_nix

if ! command -v nix >/dev/null 2>&1; then
  printf 'error: Nix was installed but is not available in this shell\n' >&2
  printf 'start a new login shell and rerun this script\n' >&2
  exit 1
fi

nix --version
printf '\nNix is ready. Open a new login shell before using it.\n'
