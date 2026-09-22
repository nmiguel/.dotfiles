#!/usr/bin/env bash
# Install pinned Nix Portable and expose it as the `nix` command.
set -Eeuo pipefail

readonly portable_version="v012"
readonly portable_x86_64_sha256="b409c55904c909ac3aeda3fb1253319f86a89ddd1ba31a5dec33d4a06414c72a"
readonly portable_aarch64_sha256="af41d8defdb9fa17ee361220ee05a0c758d3e6231384a3f969a314f9133744ea"

usage() {
  cat <<'EOF'
Usage: bootstrap-nix-portable.sh

Installs Nix Portable on x86_64 or aarch64 Linux and exposes it as `nix`.

Nix Portable does not support macOS. This script creates a /nix symlink with
sudo when necessary so store paths remain visible outside the portable
sandbox.
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

if [[ $(uname -s) != "Linux" ]]; then
  printf 'error: Nix Portable supports Linux only; use bootstrap-nix.sh on macOS\n' >&2
  exit 1
fi

case "$(uname -m)" in
  x86_64)
    portable_arch="x86_64"
    portable_sha256="$portable_x86_64_sha256"
    ;;
  aarch64 | arm64)
    portable_arch="aarch64"
    portable_sha256="$portable_aarch64_sha256"
    ;;
  *)
    printf 'error: unsupported Nix Portable architecture: %s\n' "$(uname -m)" >&2
    exit 1
    ;;
esac

if ! command -v curl >/dev/null 2>&1; then
  printf 'error: curl is required to install Nix Portable\n' >&2
  exit 1
fi

bin_dir="$HOME/.local/bin"
portable="$bin_dir/nix-portable"
portable_location="$HOME/.nix-portable"
portable_nix_root="$portable_location/nix"

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d ' ' -f 1
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | cut -d ' ' -f 1
  else
    printf 'error: sha256sum or shasum is required\n' >&2
    return 1
  fi
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

add_local_bin_to_profile() {
  local profile="$HOME/.profile"
  # Keep these variables literal until the shell profile is loaded.
  # shellcheck disable=SC2016
  local path_line='export PATH="$HOME/.local/bin:$PATH"'

  case "${SHELL:-}" in
    */bash)
      if [[ -e $HOME/.bash_profile ]]; then
        profile="$HOME/.bash_profile"
      fi
      ;;
    */zsh) profile="$HOME/.zprofile" ;;
  esac

  touch "$profile"
  if ! grep -Fqx "$path_line" "$profile"; then
    printf '\n%s\n' "$path_line" >>"$profile"
  fi
}

mkdir -p "$bin_dir"

if [[ ! -x $portable ]] || [[ $(sha256_file "$portable") != "$portable_sha256" ]]; then
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' EXIT
  download="$temp_dir/nix-portable"
  url="https://github.com/DavHau/nix-portable/releases/download/$portable_version/nix-portable-$portable_arch"

  printf 'Downloading Nix Portable %s for %s...\n' "$portable_version" "$portable_arch"
  curl --proto '=https' --tlsv1.2 --fail --location --retry 3 \
    "$url" --output "$download"

  if [[ $(sha256_file "$download") != "$portable_sha256" ]]; then
    printf 'error: Nix Portable checksum verification failed\n' >&2
    exit 1
  fi

  install -m 0755 "$download" "$portable"
else
  printf 'Pinned Nix Portable is already installed at %s\n' "$portable"
fi

for command_name in nix nix-env nix-shell nix-store; do
  command_path="$bin_dir/$command_name"
  if [[ -e $command_path && ! -L $command_path ]]; then
    printf 'error: refusing to replace %s\n' "$command_path" >&2
    exit 1
  fi
  ln -sfn nix-portable "$command_path"
done

configure_nix
add_local_bin_to_profile
export PATH="$bin_dir:$PATH"
NP_LOCATION="$HOME"
export NP_LOCATION
if [[ -z ${NP_GIT:-} ]] && command -v git >/dev/null 2>&1; then
  NP_GIT="$(command -v git)"
  export NP_GIT
fi

# The first invocation extracts Nix Portable into its persistent location.
"$portable" nix --version

if [[ ! -d $portable_nix_root/store ]]; then
  printf 'error: expected portable Nix store at %s\n' "$portable_nix_root/store" >&2
  exit 1
fi

if [[ -e /nix || -L /nix ]]; then
  if [[ ! -L /nix ]] || [[ $(readlink -f /nix) != "$(readlink -f "$portable_nix_root")" ]]; then
    printf 'error: /nix already exists and is not managed by this Nix Portable installation\n' >&2
    exit 1
  fi
else
  printf 'Creating /nix -> %s so store paths work outside the sandbox...\n' "$portable_nix_root"
  if ((EUID == 0)); then
    ln -s "$portable_nix_root" /nix
  elif command -v sudo >/dev/null 2>&1; then
    sudo ln -s "$portable_nix_root" /nix
  else
    printf 'error: sudo is required once to create the /nix symlink\n' >&2
    exit 1
  fi
fi

mkdir -p "/nix/var/nix/profiles/per-user/$(id -un)" "$HOME/.local/state/nix/profiles"
nix --version
printf '\nNix Portable is ready. Open a new login shell before using it.\n'
