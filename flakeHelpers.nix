inputs: let
  homeManagerCfg = userPackages: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = userPackages;
    home-manager.extraSpecialArgs = {
      inherit inputs;
    };
    home-manager.backupFileExtension = "bak";
  };
in {
  mkNixos = machineHostname: nixpkgsVersion: extraModules: rec {
    nixosConfigurations.${machineHostname} = nixpkgsVersion.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
      };
      modules =
        [
          ./hosts/_common
          ./hosts/${machineHostname}
          # ./modules/auto-aspm
          # Sops-nix
          inputs.sops-nix.nixosModules.sops
          # Disko
          inputs.disko.nixosModules.disko
          ./hosts/${machineHostname}/disko-config.nix
          (homeManagerCfg true)
        ]
        ++ extraModules;
    };
  };
  mkMerge = inputs.nixpkgs.lib.lists.foldl' (
    a: b: inputs.nixpkgs.lib.attrsets.recursiveUpdate a b
  ) {};
}
