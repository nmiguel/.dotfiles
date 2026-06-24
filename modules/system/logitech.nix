# LogiOps userspace driver for HID++ Logitech devices.
#
# Two-layer module: declares `systemSettings.logitech.enable` and stays inert
# until a host flips it on. Mirrors the settings from extra/logid.cfg.
{
  config,
  lib,
  ...
}:
let
  cfg = config.systemSettings.logitech;
in
{
  options.systemSettings.logitech.enable =
    lib.mkEnableOption "the LogiOps driver for Logitech devices";

  config = lib.mkIf cfg.enable {
    services.logiops = {
      enable = true;

      config = {
        devices = [
          {
            name = "MX Master 3S";

            hiresscroll = {
              hires = false;
              invert = false;
              target = false;
            };

            thumbwheel = {
              invert = false;
            };

            buttons = [
              {
                cid = 196; # 0xc4
                action = {
                  type = "Keypress";
                  keys = [ "BTN_MIDDLE" ];
                };
              }
            ];
          }
        ];
      };
    };
  };
}
