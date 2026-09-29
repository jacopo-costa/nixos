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
    ...
  } @ inputs: let
    mkNixos = (import ./flakeHelpers.nix inputs).mkNixos;

    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
  in {
    formatter = forAllSystems (pkgs: pkgs.alejandra);

    nixosConfigurations = {
      cooler = mkNixos "cooler" [
        ./modules/desktop
        ./users/jacopo
      ] "x86_64-linux";

      freezer = mkNixos "freezer" [
        ./modules/homelab
        ./modules/email
        ./users/jacopo
      ] "x86_64-linux";

      librovivo = mkNixos "librovivo" [
        ./modules/desktop
        ./users/jacopo
      ] "x86_64-linux";
    };
  };
}
