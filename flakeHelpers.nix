inputs: {
  mkNixos = machineHostname: nixpkgsVersion: extraModules: system: {
    nixosConfigurations.${machineHostname} = nixpkgsVersion.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
      };
      modules =
        [
          ./hosts/_common
          ./hosts/${machineHostname}
          # Sops-nix
          inputs.sops-nix.nixosModules.sops
          # Disko
          inputs.disko.nixosModules.disko
          ./hosts/${machineHostname}/disko-config.nix
        ]
        ++ extraModules;
    };
  };
  mergeOutputs = inputs.nixpkgs.lib.lists.foldl' (
    a: b: inputs.nixpkgs.lib.attrsets.recursiveUpdate a b
  ) {};
}
