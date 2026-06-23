# Steam game platform.
#
# Two-layer module: declares `systemSettings.steam.enable` and stays inert
# until a host flips it on.
{
  config,
  lib,
  ...
}:
let
  cfg = config.systemSettings.steam;
in
{
  options.systemSettings.steam.enable =
    lib.mkEnableOption "the Steam game platform";

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remoteplay
      dedicatedServer.openFirewall = true; # Open ports in the firewall for steam server
    };
  };
}
