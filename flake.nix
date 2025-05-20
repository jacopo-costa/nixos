{
  description = "My flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      # nothing for non-NixOS systems
    })
    // {
      nixosConfigurations = {
        cooler = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/cooler/configuration.nix
            ./modules/common.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.users.jacopo = import ./home/jacopo.nix;
            }
          ];
        };

        freezer = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/freezer/configuration.nix
            ./modules/common.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.users.ice = import ./home/ice.nix;
            }
          ];
        };
      };
    };
}
