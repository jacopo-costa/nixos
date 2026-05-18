{
  description = "My Costa Flake";

  inputs = {
    # Stable release
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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

    # Zen Browser
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    helpers = import ./flakeHelpers.nix inputs;
    inherit (helpers) mergeOutputs mkNixos;

    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
  in
    mergeOutputs [
      {
        formatter = forAllSystems (pkgs: pkgs.alejandra);
      }
      (mkNixos "cooler" nixpkgs [
        ./modules/desktop
        # Users
        ./users/jacopo
      ])
      (mkNixos "freezer" nixpkgs [
        ./modules/homelab
        ./modules/email
        # Users
        ./users/jacopo
      ])
      (mkNixos "librovivo" nixpkgs [
        ./modules/desktop
        # Users
        ./users/jacopo
      ])
    ];
}
