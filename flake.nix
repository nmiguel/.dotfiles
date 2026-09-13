{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode = {
      url = "github:anomalyco/opencode?ref=pull/5657/merge";
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

    dms-volume-mixer = {
      url = "github:cwelsys/dms-volume-mixer";
      flake = false;
    };

    dms-gpu-monitor = {
      url = "github:rollecode/dms-gpu-monitor";
      flake = false;
    };

    dank-calculator = {
      url = "github:rochacbruno/DankCalculator";
      flake = false;
    };

    # steam-pr = {
    #     url = "github:NixOS/nixpkgs/backport-524488-to-release-26.05";
    #     flake = false;
    # };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      overlays = [
        inputs.neovim-nightly-overlay.overlays.default
        (_final: _prev:
          let
            opencode = inputs.opencode.packages.${system}.default;
            node_modules = opencode.node_modules.override {
              # The synthetic merge ref changes workspace files without updating this hash.
              hash = "sha256-tHl+UGkUbalkh+C5RDkRpZ3Q87tgvqnoF4xdih6QeOw=";
            };
          in
          {
            opencode = opencode.override { inherit node_modules; };
          })
      ];
    in
    {
      # NixOS hosts. Home-manager is wired in as a NixOS module; each host
      # points nomig's home at its own home.nix.
      nixosConfigurations.tower = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/tower

          { nixpkgs.overlays = overlays; }

          home-manager.nixosModules.home-manager
        ];
      };

      nixosConfigurations.chariot = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/chariot

          { nixpkgs.overlays = overlays; }

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
          inherit overlays;
        };
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./hosts/morpheus/home.nix ];
      };
    };
}
