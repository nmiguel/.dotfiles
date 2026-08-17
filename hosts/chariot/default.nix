# Host glue for `chariot`.
{ inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix

    ../../modules/system
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users.nomig.imports = [ ./home.nix ];
}
