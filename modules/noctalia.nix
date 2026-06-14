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
in
{
  options.systemSettings.noctalia.enable =
    lib.mkEnableOption "the Noctalia desktop shell";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    # Drive the home-manager side from here so the whole shell toggles as a unit.
    home-manager.users.nomig = {
      imports = [ inputs.noctalia.homeModules.default ];
      programs.noctalia = {
        enable = true;
        systemd.enable = true;
      };
    };
  };
}
