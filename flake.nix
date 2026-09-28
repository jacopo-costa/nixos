{
  description = "My Costa Flake";

  inputs = {
    # Stable release
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    helpers = import ./flakeHelpers.nix inputs;
    mkNixos = helpers.mkNixos;

    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
  in
    nixpkgs.lib.foldl' (a: b: nixpkgs.lib.recursiveUpdate a b) {} [
      {
        formatter = forAllSystems (pkgs: pkgs.alejandra);
      }
      (mkNixos "cooler" nixpkgs [
        ./modules/desktop
        # Users
        ./users/jacopo
      ] "x86_64-linux")
      (mkNixos "freezer" nixpkgs [
        ./modules/homelab
        ./modules/email
        # Users
        ./users/jacopo
      ] "x86_64-linux")
      (mkNixos "librovivo" nixpkgs [
        ./modules/desktop
        # Users
        ./users/jacopo
      ] "x86_64-linux")
    ];
}
