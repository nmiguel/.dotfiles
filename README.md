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

