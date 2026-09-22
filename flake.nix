{
  description = "NixOS and Home Manager configurations";

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
      linuxSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin";
      overlaysFor = system: [
        inputs.neovim-nightly-overlay.overlays.default
        (_final: _prev:
          let
            opencode = inputs.opencode.packages.${system}.default;
          in
          {
            opencode = if system == linuxSystem then
              let
                node_modules = opencode.node_modules.override {
                  # The synthetic merge ref changes workspace files without updating this hash.
                  hash = "sha256-tHl+UGkUbalkh+C5RDkRpZ3Q87tgvqnoF4xdih6QeOw=";
                };
              in
              opencode.override { inherit node_modules; }
            else
              opencode;
          })
      ];
    in
    {
      # NixOS hosts. Home-manager is wired in as a NixOS module; each host
      # points nomig's home at its own home.nix.
      nixosConfigurations.tower = nixpkgs.lib.nixosSystem {
        system = linuxSystem;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/tower

          { nixpkgs.overlays = overlaysFor linuxSystem; }

          home-manager.nixosModules.home-manager
        ];
      };

      nixosConfigurations.chariot = nixpkgs.lib.nixosSystem {
        system = linuxSystem;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/chariot

          { nixpkgs.overlays = overlaysFor linuxSystem; }

          home-manager.nixosModules.home-manager
        ];
      };

      # Standalone home-manager hosts (non-NixOS, e.g. Ubuntu). Build/apply with
      #   nix run home-manager -- switch --flake .#morpheus -b backup   # first time
      #   home-manager switch --flake .#morpheus              # thereafter
      homeConfigurations.morpheus = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = linuxSystem;
          config.allowUnfree = true;
          overlays = overlaysFor linuxSystem;
        };
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./hosts/morpheus/home.nix ];
      };

      # Standalone Home Manager configuration for an Apple Silicon Mac. Apply with:
      #   nix run home-manager -- switch --flake .#magician -b backup   # first time
      #   home-manager switch --flake .#magician              # thereafter
      homeConfigurations.magician = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = darwinSystem;
          config.allowUnfree = true;
          overlays = overlaysFor darwinSystem;
        };
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./hosts/magician/home.nix ];
      };
    };
}
