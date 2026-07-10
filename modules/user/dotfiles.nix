# Dotfile deployment.
#
# Home-manager module: declares `userSettings.dotfiles.enable` and, when on,
# symlinks the tracked config trees under stow/config into ~/.config, the nvim
# submodule, and the app icons under icons/. The config/nvim links are kept
# "out of store" (they point straight at the repo checkout) so editing a file
# in the repo takes effect immediately, without a home-manager rebuild — which
# is why the module needs to know where that checkout lives (`repoRoot`).
{
  config,
  lib,
  ...
}:
let
  cfg = config.userSettings.dotfiles;

  configDir = ../../stow/config;

  # Every entry under stow/config becomes a matching ~/.config/<name> symlink.
  configEntries = builtins.listToAttrs (
    map (name: {
      name = ".config/${name}";
      value.source = config.lib.file.mkOutOfStoreSymlink "${cfg.repoRoot}/stow/config/${name}";
    }) (builtins.attrNames (builtins.readDir configDir))
  );

  # icons/ ships bespoke app icons into the user's hicolor icon theme.
  iconEntries = builtins.listToAttrs (
    map (name: {
      name = ".local/share/icons/hicolor/128x128/apps/${name}";
      value.source = ../../icons + "/${name}";
    }) (builtins.attrNames (builtins.readDir ../../icons))
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
  };

  config = lib.mkIf cfg.enable {
    home.file =
      configEntries
      // iconEntries
      // {
        # nvim is a git submodule, so the readDir above doesn't pick it up.
        ".config/nvim".source =
          config.lib.file.mkOutOfStoreSymlink "${cfg.repoRoot}/stow/config/nvim";
      };
  };
}
