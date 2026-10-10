# Noctalia desktop shell.
#
# Two-layer module: declares the `systemSettings.noctalia.enable` flag and
# stays inert until a host flips it on. When enabled it is self-contained
# across both layers — it installs the system package and configures the
# per-user (home-manager) side — so flipping the single flag is all that's
# needed.
{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.systemSettings.noctalia;
  package = pkgs.noctalia;
in
{
  options.systemSettings.noctalia.enable = lib.mkEnableOption "the Noctalia desktop shell";

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
    hardware.graphics.enable = lib.mkDefault true;

    # Native clipboard history and calendar storage use Secret Service.
    services.gnome.gnome-keyring.enable = true;

    # Drive the home-manager side from here so the whole shell toggles as a unit.
    home-manager.users.nomig = { config, lib, ... }: {
      programs.noctalia = {
        enable = true;
        inherit package;
        systemd.enable = true;
      };

      # GUI overrides load after ~/.config/noctalia/*.toml. Keep them writable
      # and repo-backed without tracking clipboard history or other runtime state.
      home.file."${config.xdg.stateHome}/noctalia/settings.toml".source =
        config.lib.file.mkOutOfStoreSymlink
          "${config.userSettings.dotfiles.repoRoot}/stow/state/noctalia/settings.toml";

      # Retire the previous layout once, before installing the settings link.
      home.activation.noctaliaDmsMigration = lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] ''
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
