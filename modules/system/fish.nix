# Fish shell, with a bash drop-in for non-fish parent shells.
#
# Two-layer module: declares `systemSettings.fish.enable` and stays inert
# until a host flips it on.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.systemSettings.fish;
in
{
  options.systemSettings.fish.enable =
    lib.mkEnableOption "the Fish shell as the login shell";

  config = lib.mkIf cfg.enable {
    users.users.nomig.shell = "${pkgs.fish}/bin/fish";
    programs.bash = {
      interactiveShellInit = ''
        # "check if parent process is not fish" && "make nested shells work properly"
        if grep -qv fish /proc/$PPID/comm && [[ $SHLVL == [12] ]]; then
            # set $SHELL for better integration with programs like nix shell, tmux, etc.
            SHELL=${pkgs.fish}/bin/fish exec fish
        fi
      '';
    };
  };
}
