# Home-manager configuration for nomig on `tower`.
#
# tower is a full NixOS desktop, so it opts into everything: the shared
# dotfiles, theming and package sets live in modules/user (reusable by other
# hosts), and are switched on here via userSettings.
{ ... }:

{
  # Auto-imports every user (home-manager) module under modules/user.
  imports = [ ../../modules/user ];

  userSettings = {
    # Shared feature modules.
    dotfiles.enable = true;
    defaultApps.enable = true;
    theming.enable = true;
    packages.cli.enable = true;
    packages.gui.enable = true;
    desktop.enable = true;

    # Per-language development toolchains (see modules/user/<lang>.nix).
    python.enable = true;
    rust.enable = true;
    lua.enable = true;
    go.enable = true;
    js.enable = true;
  };

  home.username = "nomig";
  home.homeDirectory = "/home/nomig";
  home.stateVersion = "25.11";
}
