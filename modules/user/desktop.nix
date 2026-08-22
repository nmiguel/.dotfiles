# Web application desktop entries.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.userSettings.desktop;

  webAppIcons = pkgs.runCommand "web-app-icons" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
    mkdir -p "$out"
    magick 'ico:${../../icons/claude.png}[0]' -background none -resize 128x128 -gravity center -extent 128x128 "$out/claude.png"
    magick '${../../icons/chatgpt.png}' -background none -resize 128x128 -gravity center -extent 128x128 "$out/chatgpt.png"
    magick '${../../icons/whatsapp.png}' -background none -resize 128x128 -gravity center -extent 128x128 "$out/whatsapp.png"
    magick '${../../icons/discord.png}' -background none -resize 128x128 -gravity center -extent 128x128 "$out/discord.png"
  '';
in
{
  options.userSettings.desktop.enable =
    lib.mkEnableOption "web application desktop entries";

  config = lib.mkIf cfg.enable {
    xdg.desktopEntries.claude = {
      name = "Claude";
      genericName = "AI Assistant";
      exec = "chromium --app=https://claude.ai --class=claude";
      icon = "claude";
      comment = "Claude AI";
      settings.StartupWMClass = "claude";
    };

    xdg.desktopEntries.chatgpt = {
      name = "ChatGPT";
      genericName = "AI Assistant";
      exec = "chromium --app=https://chatgpt.com";
      icon = "chatgpt";
      comment = "ChatGPT";
      settings.StartupWMClass = "chrome-chatgpt.com__-Default";
    };

    xdg.desktopEntries.whatsapp = {
      name = "WhatsApp";
      genericName = "WhatsApp";
      exec = "chromium --app=https://web.whatsapp.com";
      icon = "whatsapp";
      comment = "WhatsApp";
      settings.StartupWMClass = "chrome-web.whatsapp.com__-Default";
    };

    xdg.desktopEntries.discord = {
      name = "Discord";
      genericName = "Chat";
      exec = "chromium --app=https://discord.com/app";
      icon = "discord";
      comment = "Discord";
      settings.StartupWMClass = "chrome-discord.com__app-Default";
    };

    xdg.dataFile = {
      "icons/hicolor/128x128/apps/claude.png".source = "${webAppIcons}/claude.png";
      "icons/hicolor/128x128/apps/chatgpt.png".source = "${webAppIcons}/chatgpt.png";
      "icons/hicolor/128x128/apps/whatsapp.png".source = "${webAppIcons}/whatsapp.png";
      "icons/hicolor/128x128/apps/discord.png".source = "${webAppIcons}/discord.png";
    };
  };
}
