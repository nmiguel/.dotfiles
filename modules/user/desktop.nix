# Web application desktop entries.
{
  config,
  lib,
  ...
}:
let
  cfg = config.userSettings.desktop;
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
    };

    xdg.desktopEntries.chatgpt = {
      name = "ChatGPT";
      genericName = "AI Assistant";
      exec = "chromium --app=https://chatgpt.com";
      icon = "chatgpt";
      comment = "ChatGPT";
    };

    xdg.desktopEntries.whatsapp = {
      name = "WhatsApp";
      genericName = "WhatsApp";
      exec = "chromium --app=https://web.whatsapp.com";
      icon = "whatsapp";
      comment = "WhatsApp";
    };
  };
}
