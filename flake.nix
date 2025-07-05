{
  description = "My Costa Flake";

  inputs = {
    # Stable release
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disko
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Sops secrets
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    home-manager,
    sops-nix,
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
          experimental-features = ["nix-command" "flakes"];
          auto-optimise-store = true;
        };

        nix.gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };

        nixpkgs.config.allowUnfree = true;
      }
    ];
  in {
    # Set formatter to alejandra
    formatter.${system} = pkgs.alejandra;

    nixosConfigurations = {
      cooler = nixpkgs.lib.nixosSystem {
        inherit system;

        modules =
          sharedModules
          ++ [
            # Main config
            ./hosts/cooler

            # Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users = {
                jacopo = import ./users/jacopo/home.nix;
              };
            }

            # Disko
            # disko.nixosModules.disko
            # ./hosts/cooler/disko-config.nix

            # Sops
            sops-nix.nixosModules.sops
          ];
      };

      librovivo = nixpkgs.lib.nixosSystem {
        inherit system;

        modules =
          sharedModules
          ++ [
            # Main config
            ./hosts/librovivo

            # Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users = {
                jacopo = import ./users/jacopo/home.nix;
              };
            }

            # Disko
            # disko.nixosModules.disko
            # ./hosts/librovivo/disko-config.nix

            # Sops
            sops-nix.nixosModules.sops
          ];
      };

      freezer = nixpkgs.lib.nixosSystem {
        inherit system;

        modules =
          sharedModules
          ++ [
            # Main config
            ./hosts/freezer

            # Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users = {
                ice = import ./users/ice/home.nix;
              };
            }

            # Disko
            disko.nixosModules.disko
            ./hosts/freezer/disko-config.nix

            # Sops
            sops-nix.nixosModules.sops
          ];
      };
    };
  };
}
