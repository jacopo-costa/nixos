inputs: {
  mkNixos = machineHostname: extraModules: system:
    inputs.nixpkgs.lib.nixosSystem {
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
}
