# Hyprland Wayland compositor.
#
# Two-layer module: declares `systemSettings.hyprland.enable` and configures
# both the system side (the compositor, xdg portals) and the per-user
# (home-manager) side, so the whole thing toggles as a unit.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.systemSettings.hyprland;
in
{
  options.systemSettings.hyprland = {
    enable = lib.mkEnableOption "the Hyprland Wayland compositor";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true; # recommended for most users
      xwayland.enable = true; # Xwayland can be disabled.
    };

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
        # xdg-desktop-portal-gnome
      ];
    };

    environment.systemPackages = with pkgs; [
      hyprland
      hyprland-qtutils
    ];

    # Drive the home-manager side from here so the whole shell toggles as a unit.
    home-manager.users.nomig = {
      wayland.windowManager.hyprland = {
        enable = true;
        package = null;
        portalPackage = null;
        systemd.enable = false;
        configType = "lua";
      };
    };
  };
}
