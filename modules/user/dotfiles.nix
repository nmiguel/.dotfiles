# Dotfile deployment.
#
# Home-manager module: declares `userSettings.dotfiles.enable` and, when on,
# symlinks the tracked trees under stow/config into ~/.config and stow/home
# into ~/. The links are kept "out of store" (they point
# straight at the repo checkout) so editing a file in the repo takes effect
# immediately, without a home-manager rebuild — which is why the module needs
# to know where that checkout lives (`repoRoot`).
{
  config,
  lib,
  ...
}:
let
  cfg = config.userSettings.dotfiles;

  configDir = ../../stow/config;
  homeDir = ../../stow/home;
  availableEntries = lib.unique (
    builtins.attrNames (builtins.readDir configDir) ++ [ "nvim" ]
  );
  selectedEntries = if cfg.entries == null then availableEntries else cfg.entries;

  # Selected entries under stow/config become matching ~/.config/<name> links.
  configEntries = builtins.listToAttrs (
    map (name: {
      name = ".config/${name}";
      value.source = config.lib.file.mkOutOfStoreSymlink "${cfg.repoRoot}/stow/config/${name}";
    }) selectedEntries
  );

  # Entries under stow/home become matching files or directories in ~/.
  homeEntries = builtins.listToAttrs (
    map (name: {
      inherit name;
      value.source = config.lib.file.mkOutOfStoreSymlink "${cfg.repoRoot}/stow/home/${name}";
    }) (builtins.attrNames (builtins.readDir homeDir))
  );
in
{
  options.userSettings.dotfiles = {
    enable = lib.mkEnableOption "symlinking the tracked dotfiles into $HOME";

    repoRoot = lib.mkOption {
      type = lib.types.str;
      default = "/home/nomig/projects/personal/.dotfiles";
      description = ''
        Absolute path to this repository's checkout on the target machine.
        Used to build the out-of-store symlinks for ~/.config so edits in the
        repo take effect without a home-manager rebuild.
      '';
    };

    entries = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf (lib.types.enum availableEntries));
      default = null;
      description = "Dotfile entries to link, or all tracked entries when null.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file = configEntries // homeEntries;
  };
}
