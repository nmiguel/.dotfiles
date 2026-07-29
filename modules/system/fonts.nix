# Desktop and programming fonts.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.systemSettings.fonts;
in
{
  options.systemSettings.fonts.enable = lib.mkEnableOption "the system desktop and programming fonts";

  config = lib.mkIf cfg.enable {
    fonts.packages = with pkgs; [
      fira-sans
      inter
      noto-fonts
      source-sans
      source-serif

      nerd-fonts.caskaydia-mono
      nerd-fonts.commit-mono
      nerd-fonts.fira-mono
      nerd-fonts.jetbrains-mono
    ];

    fonts.fontconfig.defaultFonts = {
      sansSerif = [
        "Fira Sans"
        "Noto Sans"
      ];
      serif = [ "Noto Serif" ];
    };
  };
}
