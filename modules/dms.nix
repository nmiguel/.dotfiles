# DankMaterialShell (dms) desktop shell.
#
# Two-layer module: declares the `systemSettings.dms.enable` flag and stays
# inert until a host flips it on. The upstream NixOS module is always imported
# (so its options exist) but nothing it provides activates unless the flag is
# set. dms is configured entirely on the NixOS side.
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
  imports = [
    inputs.dms.nixosModules.dank-material-shell
  ];

  options.systemSettings.dms.enable =
    lib.mkEnableOption "the DankMaterialShell desktop shell";

  config = lib.mkIf cfg.enable {
    programs.dank-material-shell = {
      enable = true;
      package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;

      systemd = {
        enable = true; # Systemd service for auto-start
        restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
      };

      # Core features
      enableSystemMonitoring = true; # System monitoring widgets (dgop)
      enableVPN = false; # VPN management widget
      enableDynamicTheming = true; # Wallpaper-based theming (matugen)
      enableAudioWavelength = false; # Audio visualizer (cava)
      enableCalendarEvents = true; # Calendar integration (khal)
      enableClipboardPaste = true; # Pasting from the clipboard history (wtype)
    };
  };
}
