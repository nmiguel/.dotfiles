# OpenRGB server and declarative startup profiles.
{
  config,
  lib,
  ...
}:
let
  cfg = config.systemSettings.openrgb;
  openrgb = lib.getExe config.services.hardware.openrgb.package;
in
{
  options.systemSettings.openrgb = {
    enable = lib.mkEnableOption "OpenRGB lighting control";

  };

  config = lib.mkIf cfg.enable {
    services.hardware.openrgb = {
      enable = true;
      # startupProfile = "all-off";
      startupProfile = "all-light-blue";
    };

    # OpenRGB profiles contain detected controller metadata, so generate them
    # on the target machine before starting the server.
    systemd.services.openrgb.preStart = ''
      ${openrgb} --noautoconnect --config /var/lib/OpenRGB --mode static --color 000000 --save-profile all-off
      ${openrgb} --noautoconnect --config /var/lib/OpenRGB --mode static --color 57A3FF --save-profile all-light-blue
    '';
  };
}
