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
          ./modules/email
          ./modules/auto-aspm
          inputs.sops-nix.nixosModules.sops
          (homeManagerCfg true)
        ]
        ++ extraModules;
    };
  };
  mkMerge = inputs.nixpkgs.lib.lists.foldl' (
    a: b: inputs.nixpkgs.lib.attrsets.recursiveUpdate a b
  ) {};
}
