# SDDM display manager.
#
# Two-layer module: declares `systemSettings.sddm.enable` and stays inert
# until a host flips it on.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.systemSettings.sddm;
in
{
  options.systemSettings.sddm.enable =
    lib.mkEnableOption "the SDDM display manager";

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;

      autoNumlock = true;

      extraPackages = with pkgs; [
        sddm-astronaut
      ];

      theme = "sddm-astronaut-theme";
      settings = {
        Theme = {
          Current = "sddm-astronaut-theme";
        };
      };
    };

    environment.systemPackages = with pkgs; [
      (sddm-astronaut.override {
        embeddedTheme = "pixel_sakura";
      })
    ];
  };
}
