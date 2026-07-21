# System-level gaming support.
#
# Enables Steam and its required system integration. The matching user module
# installs user-level gaming applications from the same host flag.
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.games;
in
{
  options.modules.games.enable =
    lib.mkEnableOption "system-level gaming support";

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };
}
