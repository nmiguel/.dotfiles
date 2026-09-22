Just a place for my dotfiles.

# Nix bootstrap

For a normal Nix installation on macOS or Linux:

```sh
./scripts/bootstrap-nix.sh
```

The script only installs official multi-user Nix and enables flakes. The official installer selects the appropriate build for the operating system and architecture. Open a new login shell after bootstrapping.

Nix Portable is available as a separate Linux-only bootstrap:

```sh
./scripts/bootstrap-nix-portable.sh
```

The script selects the download matching the Linux architecture and creates a `/nix` symlink, using `sudo` once, so Nix store paths remain available outside the portable sandbox.

# After bootstrapping

Open a new login shell, return to this repository, and initialize its
submodules:

```sh
git submodule update --init --recursive
```

For a NixOS machine, apply its complete system configuration:

```sh
sudo nixos-rebuild switch --flake .#tower
sudo nixos-rebuild switch --flake .#chariot
```

Run only the command for the current machine.

For a standalone Home Manager machine, use `nix run` for the first activation:

```sh
nix run home-manager -- switch --flake .#magician -b backup
nix run home-manager -- switch --flake .#hermit -b backup
```

Again, run only the command for the current machine. The backup flag preserves
files that conflict with the managed dotfiles. After the first activation, use
the installed `home-manager` command:

```sh
home-manager switch --flake .#magician
home-manager switch --flake .#hermit
```

# Hosts

| Host | Configuration | Description |
| --- | --- | --- |
| `tower` | NixOS | Main desktop |
| `chariot` | NixOS | Home server |
| `magician` | Home Manager (`aarch64-darwin`) | macOS work laptop |
| `hermit` | Home Manager (`x86_64-linux`) | Headless VM |
