# Desktop theming.
#
# Home-manager module: declares `userSettings.theming.enable` and, when on,
# applies a consistent dark look across GTK and Qt, the Bibata cursor, and a
# prefers-dark hint for GNOME apps via dconf.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.userSettings.theming;
in
{
  options.userSettings.theming.enable =
    lib.mkEnableOption "the dark GTK/Qt desktop theme and cursor";

  config = lib.mkIf cfg.enable {
    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      gtk4.theme = config.gtk.theme;
      gtk4.iconTheme = config.gtk.iconTheme;
      gtk3.theme = config.gtk.theme;
      gtk3.iconTheme = config.gtk.iconTheme;
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk3";
    };

    home.pointerCursor = {
      enable = true;
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
  };
}
