# Git and Jujutsu share a per-host commit identity.
{ config, lib, pkgs, ... }:
let
  cfg = config.userSettings.vcs;
  identity = {
    name = cfg.name;
    email = cfg.email;
  };
in
{
  options.userSettings.vcs = {
    enable = lib.mkEnableOption "the shared Git and Jujutsu configuration" // {
      default = config.userSettings.packages.cli.enable;
    };

    name = lib.mkOption {
      type = lib.types.str;
      default = "Nuno Ramos";
      description = "Author name used by both Git and Jujutsu.";
    };

    email = lib.mkOption {
      type = lib.types.str;
      default = "nmiguel123@gmail.com";
      description = "Author email used by both Git and Jujutsu.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings = {
        user = identity;
        init.defaultBranch = "master";
        alias.readd = "update-index --again";
        rerere.enabled = true;
        credential = {
          helper = "store";
          "https://github.com".helper = [
            ""
            "!${lib.getExe pkgs.gh} auth git-credential"
            # The old config tried the global store helper after gh as well.
            "store"
          ];
        };
      };
    };

    programs.jujutsu = {
      enable = true;
      settings = {
        user = identity;
        revset-aliases."closest_bookmark(to)" = "heads(::to & bookmarks())";
        aliases = {
          tug = [ "bookmark" "move" "--from" "closest_bookmark(@-)" "--to" "@-" ];
          c = [ "commit" ];
          ci = [ "commit" "--interactive" ];
          e = [ "edit" ];
          i = [ "git" "init" "--colocate" ];
          nb = [ "bookmark" "create" "-r @-" ]; # New bookmark.
          pull = [ "git" "fetch" ];
          push = [ "git" "push" "--allow-new" ];
          r = [ "rebase" ];
          s = [ "squash" ];
          si = [ "squash" "--interactive" ];
        };
      };
    };


    home.packages = with pkgs; [
      jjui
    ];
  };
}
