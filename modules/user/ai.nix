# Shared AI tools and OpenCode quota sidebar configuration.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  # The pinned OpenCode 1 release needs Quota 4; Quota 5 requires OpenCode 2.
  quotaPlugin = "@slkiser/opencode-quota@4.10.7";
  opencodeSettings = builtins.fromJSON (builtins.readFile ../../stow/config/opencode/opencode.json);
  jsonFormat = pkgs.formats.json { };
in
{
  config = lib.mkIf config.userSettings.packages.cli.enable {
    assertions = [
      {
        assertion =
          !(lib.any (
            file:
            file.target == lib.removePrefix "${config.home.homeDirectory}/" "${config.xdg.configHome}/opencode"
          ) (lib.attrValues config.home.file));
        message = "OpenCode needs a writable config directory. Manage its individual config files with programs.opencode; do not symlink .config/opencode as a whole directory.";
      }
    ];

    programs.opencode = {
      enable = true;
      settings = lib.mkMerge [
        opencodeSettings
        { plugin = [ quotaPlugin ]; }
      ];
      tui.plugin = [ quotaPlugin ];
    };

    xdg.configFile."opencode/opencode-quota/quota-toast.json".source =
      jsonFormat.generate "quota-toast.json"
        {
          enabledProviders = "auto";
          formatStyle = "allWindows";
          tuiSidebarPanel.enabled = true;
          enableToast = false;
          tuiCompactStatus.enabled = false;
        };
  };
}
