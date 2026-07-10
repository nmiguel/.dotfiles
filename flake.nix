{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # steam-pr = {
    #     url = "github:NixOS/nixpkgs/backport-524488-to-release-26.05";
    #     flake = false;
    # };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      # NixOS hosts. Home-manager is wired in as a NixOS module; each host
      # points nomig's home at its own home.nix.
      nixosConfigurations.tower = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/tower

          home-manager.nixosModules.home-manager
        ];
      };

      # Standalone home-manager hosts (non-NixOS, e.g. Ubuntu). Build/apply with
      #   nix run home-manager -- switch --flake .#morpheus   # first time
      #   home-manager switch --flake .#morpheus              # thereafter
      homeConfigurations.morpheus = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./hosts/morpheus/home.nix ];
      };
    };
}
