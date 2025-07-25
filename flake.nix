{
  description = "My Costa Flake";

  inputs = {
    # Stable release
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # Flake Utils
    flake-utils.url = "github:numtide/flake-utils";

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

    # Arion
    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    flake-utils,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    helpers = import ./flakeHelpers.nix inputs;
    inherit (helpers) mkMerge mkNixos;
  in
    mkMerge [
      (flake-utils.lib.eachDefaultSystem (
        system: let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          packages.default = pkgs.mkShell {
            packages = [
              pkgs.just
              pkgs.nixos-rebuild
            ];
          };
          formatter = pkgs.alejandra;
        }
      ))
      (mkNixos "cooler" inputs.nixpkgs [
        ./desktop
        # Users
        ./users/jacopo
        home-manager.nixosModules.home-manager
        {
          home-manager.users = {
            jacopo = import ./users/jacopo/home.nix;
          };
        }
      ])
      (mkNixos "freezer" inputs.nixpkgs [
        inputs.arion.nixosModules.arion
        ./homelab
        ./modules/email
        # Users
        ./users/ice
        home-manager.nixosModules.home-manager
        {
          home-manager.users = {
            ice = import ./users/ice/home.nix;
          };
        }
      ])
      (mkNixos "librovivo" inputs.nixpkgs [
        ./desktop
        # Users
        ./users/jacopo
        home-manager.nixosModules.home-manager
        {
          home-manager.users = {
            jacopo = import ./users/jacopo/home.nix;
          };
        }
      ])
    ];
}
