# Home-manager configuration for nomig on the headless `chariot` host.
{ ... }:

{
  imports = [ ../../modules/user ];

  userSettings = {
    dotfiles.enable = true;
    theming.enable = false;
    packages.cli.enable = true;
    packages.gui.enable = false;
    desktop.enable = false;

    python.enable = true;
    rust.enable = true;
    lua.enable = true;
    go.enable = true;
    js.enable = true;
  };

  home.username = "nomig";
  home.homeDirectory = "/home/nomig";
  home.stateVersion = "26.05";
}
