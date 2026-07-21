# Host glue for `tower`.
#
# Wires the pieces of this host together: the machine's hardware scan, its
# system configuration (which sets the host feature flags), and the shared
# feature modules. The modules are imported here so their options exist
# everywhere, but each stays inert until configuration.nix flips its flag.
#
# The host also owns its home-manager configuration, so different hosts can
# point nomig's home at their own home.nix.
{ inputs, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix

    # Auto-imports every feature module under modules/system.
    ../../modules/system
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users.nomig = {
    imports = [ ./home.nix ];
    modules.games.enable = config.modules.games.enable;
  };
}
