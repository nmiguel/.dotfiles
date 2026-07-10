# Home-manager configuration for nomig on `morpheus`.
#
# morpheus is an Ubuntu machine (not NixOS), so home-manager runs in
# standalone mode — it manages only this user's packages and dotfiles, not the
# system. The flake exposes it as `homeConfigurations.morpheus`; apply it with:
#
#     home-manager switch --flake .#morpheus
#
# It reuses the same modules/user feature set as tower; trim the userSettings
# below if some desktop packages don't make sense on this box.
{ ... }:

{
  # Auto-imports every user (home-manager) module under modules/user.
  imports = [ ../../modules/user ];

  userSettings = {
    # Shared feature modules.
    dotfiles.enable = true;
    # Point this at wherever the repo is checked out on morpheus if it differs.
    # dotfiles.repoRoot = "/home/nomig/.dotfiles";
    theming.enable = true;
    packages.cli.enable = true;
    packages.gui.enable = true;

    # Per-language development toolchains (see modules/user/<lang>.nix).
    python.enable = true;
    rust.enable = true;
    lua.enable = true;
    go.enable = true;
  };

  home.username = "nomig";
  home.homeDirectory = "/home/nomig";
  home.stateVersion = "25.11";

  # Non-NixOS host: make home-manager set up session variables, XDG paths and
  # make Nix-installed desktop apps show up in the Ubuntu launcher.
  targets.genericLinux.enable = true;

  # Let home-manager manage its own installation on this standalone host.
  programs.home-manager.enable = true;
}
