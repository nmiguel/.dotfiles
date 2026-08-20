# 1Password desktop application, CLI, and browser integration.
{
  config,
  lib,
  ...
}:
let
  cfg = config.systemSettings.onepassword;
in
{
  options.systemSettings.onepassword = {
    enable = lib.mkEnableOption "1Password";

    polkitPolicyOwners = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Users allowed to authenticate polkit requests with 1Password.";
    };

    browserExtensions.enable = lib.mkEnableOption "1Password browser extensions";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        programs._1password.enable = true;
        programs._1password-gui = {
          enable = true;
          inherit (cfg) polkitPolicyOwners;
        };
      }

      (lib.mkIf (cfg.browserExtensions.enable && config.programs.firefox.enable) {
        programs.firefox.policies.ExtensionSettings."{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
      })

      # This option enables policies rather than installing a browser. NixOS
      # writes the policy for Chromium, Google Chrome, and Brave.
      (lib.mkIf cfg.browserExtensions.enable {
        programs.chromium = {
          enable = true;
          extensions = [ "aeblfdkhhhdcdjpifhhbdiojplfjncoa" ];
        };
      })
    ]
  );
}
