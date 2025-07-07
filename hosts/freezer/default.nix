{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./network.nix

    ../../modules/homelab
    ../../modules/locale.nix

    # Users
    ../../users/ice
  ];

  # Sops secrets
  sops = {
    # Where the generated secrets with sops <filename> is
    defaultSopsFile = ../../secrets.yaml;
    defaultSopsFormat = "yaml";

    # Where the private key is
    age.keyFile = "/etc/sops/age/keys.txt";
    age.generateKey = false;
  };

  # ZFS
  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs.extraPools = [ "tank" ];
  };
}
