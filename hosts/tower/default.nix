# Host glue for `tower`.
#
# Wires the pieces of this host together: the machine's hardware scan, its
# system configuration (which sets the systemSettings flags), and the shared
# feature modules. The modules are imported here so their options exist
# everywhere, but each stays inert until configuration.nix flips its flag.
{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix

    ../../modules/noctalia.nix
    ../../modules/dms.nix
  ];
}
