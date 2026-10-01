# Noctalia desktop shell.
#
# Two-layer module: declares the `systemSettings.noctalia.enable` flag and
# stays inert until a host flips it on. When enabled it is self-contained
# across both layers — it installs the system package and configures the
# per-user (home-manager) side — so flipping the single flag is all that's
# needed.
{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.systemSettings.noctalia;
  package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [ inputs.noctalia.nixosModules.default ];

  options.systemSettings.noctalia.enable =
    lib.mkEnableOption "the Noctalia desktop shell";

  config = lib.mkIf cfg.enable {
    # Publish the active shell for the Hyprland config to branch on, mirroring
    # the monitors.lua pattern. A Lua module so it can be read with dofile.
    environment.etc."hypr/shell.lua".text = ''return "noctalia"'';

    programs.noctalia = {
      enable = true;
      inherit package;
      recommendedServices.enable = true;
    };

    environment.systemPackages = [ pkgs.nixos-icons ];

    # Native clipboard history and calendar storage use Secret Service.
    services.gnome.gnome-keyring.enable = true;

    # Drive the home-manager side from here so the whole shell toggles as a unit.
    home-manager.users.nomig = { config, lib, ... }: {
      imports = [ inputs.noctalia.homeModules.default ];
      programs.noctalia = {
        enable = true;
        inherit package;
        systemd.enable = true;
      };

      # Noctalia loads GUI overrides after the stowed TOML. Retire the previous
      # layout once, preserving it and leaving subsequent GUI changes writable.
      home.activation.noctaliaDmsMigration = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        stateDir=${lib.escapeShellArg "${config.xdg.stateHome}/noctalia"}
        if [ ! -e "$stateDir/.dms-migration-v1" ]; then
          run mkdir -p "$stateDir"
          if [ -e "$stateDir/settings.toml" ] || [ -L "$stateDir/settings.toml" ]; then
            run mv --backup=numbered "$stateDir/settings.toml" "$stateDir/settings.toml.before-dms-migration"
          fi
          run touch "$stateDir/.dms-migration-v1"
        fi
      '';
    };
  };
}
