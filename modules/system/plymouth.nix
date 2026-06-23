# Plymouth boot splash and silent boot.
#
# Two-layer module: declares `systemSettings.plymouth.enable` and stays inert
# until a host flips it on.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.systemSettings.plymouth;
in
{
  options.systemSettings.plymouth.enable =
    lib.mkEnableOption "the Plymouth boot splash and silent boot";

  config = lib.mkIf cfg.enable {
    boot = {
      plymouth = {
        enable = true;
        theme = "lone";
        themePackages = with pkgs; [
          # By default we would install all themes
          (adi1090x-plymouth-themes.override {
            selected_themes = [ "lone" ];
          })
        ];
      };

      # Enable "Silent boot"
      consoleLogLevel = 3;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "splash"
        "rd.udev.log_level=3"
        "rd.systemd.show_status=auto"
      ];
    };
  };
}
