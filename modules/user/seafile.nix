# Seafile desktop sync client.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.userSettings.seafile;
  seafileClient = pkgs.seafile-client.overrideAttrs (oldAttrs: {
    qtWrapperArgs = (oldAttrs.qtWrapperArgs or [ ]) ++ [
      "--prefix XDG_DATA_DIRS : ${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    ];
  });
in
{
  options.userSettings.seafile.enable =
    lib.mkEnableOption "the Seafile desktop sync client";

  config = lib.mkIf cfg.enable {
    home.packages = [ seafileClient ];

    systemd.user.services.seafile-client = {
      Unit = {
        Description = "Seafile desktop sync client";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${seafileClient}/bin/seafile-applet";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
