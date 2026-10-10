# DankMaterialShell (dms) desktop shell.
#
# Two-layer module: declares the `systemSettings.dms.enable` flag and stays
# inert until a host flips it on. Uses the native nixpkgs module and is
# configured entirely on the NixOS side.
{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.systemSettings.dms;
in
{
  options.systemSettings.dms.enable = lib.mkEnableOption "the DankMaterialShell desktop shell";

  config = lib.mkIf cfg.enable {
    # Publish the active shell for the Hyprland config to branch on, mirroring
    # the monitors.lua pattern. A Lua module so it can be read with dofile.
    environment.etc."hypr/shell.lua".text = ''return "dms"'';

    environment.systemPackages = [
      pkgs.papirus-icon-theme
      pkgs.khal # Calendar backend; select it in DMS settings.
    ];

    services.power-profiles-daemon.enable = lib.mkDefault true;
    services.geoclue2.enable = lib.mkDefault true;
    security.polkit.enable = lib.mkDefault true;

    systemd.user.services.dms.environment = {
      QT_QPA_PLATFORMTHEME = "gtk3";
      QS_ICON_THEME = "Papirus-Dark";
    };

    programs.dms-shell = {
      enable = true;
      package = pkgs.dms-shell;

      systemd = {
        enable = true; # Systemd service for auto-start
        restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
      };

      # Monitoring and clipboard support are built in; matugen is included
      # by the native module. Keep the optional audio visualizer excluded.
      excludePackages = [ pkgs.cava ];

      plugins = {
        volumeMixer.src = inputs.dms-volume-mixer;
        calculator.src = inputs.dank-calculator;
      };
    };
  };
}
