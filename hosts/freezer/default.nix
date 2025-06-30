{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    ../../modules/homelab
    ../../modules/locale.nix

    # Users
    ../../users/ice
  ];

  # Networking
  networking = {
    useNetworkd = true;
    networkmanager.enable = false;

    firewall.enable = true;

    # Disable DHCP on individual interfaces
    interfaces.enp3s0.useDHCP = false;
    interfaces.enp4s0.useDHCP = false;

    bonds.bond0 = {
      interfaces = ["enp3s0" "enp4s0"];
      driverOptions = {
        miimon = "100";
        mode = "active-backup";
        primary = "enp3s0";
      };
    };

    # Use DHCP
    interfaces.bond0.useDHCP = true;

    hostName = "freezer";
  };
}