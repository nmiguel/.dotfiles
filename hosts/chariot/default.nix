# Host glue for `chariot`.
{ inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix
    ./llm.nix

    ../../modules/system

    inputs.sops-nix.nixosModules.sops
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users.nomig.imports = [ ./home.nix ];
}
