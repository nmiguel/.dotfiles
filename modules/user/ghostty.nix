# Shared Ghostty settings; macOS uses a separately installed native app.
{ config, lib, pkgs, ... }:
{
  options.userSettings.ghostty.enable = lib.mkEnableOption "the shared Ghostty configuration";

  config = lib.mkIf config.userSettings.ghostty.enable {
    programs.ghostty = {
      enable = true;
      package = if pkgs.stdenv.hostPlatform.isDarwin then null else pkgs.ghostty;
      settings = {
        command = "tmux";
        font-family = "CommitMono";
        font-feature = "liga=1";
        font-size = 16;
        adjust-underline-thickness = 1;
        adjust-cursor-thickness = 1;
        adjust-box-thickness = 1;
        mouse-scroll-multiplier = 0.5;
        mouse-hide-while-typing = true;
        window-padding-x = 10;
        window-padding-y = 10;
        link-url = true;
        link-previews = true;
        confirm-close-surface = false;
        shell-integration = "fish";
        window-decoration = "none";
        theme = "TokyoNight Moon";
        cursor-color = "#abb2bf";
        selection-background = "#323844";
        selection-foreground = "#abb2bf";
        background = "#131a21";
        foreground = "#e0e0e0";
        background-opacity = 0.75;
        clipboard-read = "allow";
        clipboard-write = "allow";
        copy-on-select = "clipboard";
      };
    };
  };
}
