# User-level gaming applications.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.games;
in
{
  options.modules.games.enable = lib.mkEnableOption "user-level gaming applications";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      lutris
      heroic
      # wine
    ];
  };
}
