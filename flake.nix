{
  description = "My Costa Flake";

  inputs = {
    # Stable release
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # Home Manager, follows pkgs stable release
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    sharedModules = [
      # Set optimize store and generation for every hosts
      {
        nix.settings = {
          auto-optimise-store = true;
        };

        nix.gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };
      }
    ];
  in {
    # Set formatter to alejandra
    formatter.${system} = pkgs.alejandra;

    nixosConfigurations = {
      cooler = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {inherit pkgs home-manager;};

        modules =
          sharedModules
          ++ [
            ./hosts/cooler
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users = {
                jacopo = import ./users/jacopo/home.nix;
              };
            }
          ];
      };

      freezer = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {inherit pkgs;};

        modules =
          sharedModules
          ++ [
            ./hosts/freezer
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users = {
                ice = import ./users/ice/home.nix;
              };
            }
          ];
      };
    };
  };
}
