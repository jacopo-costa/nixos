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
    firewall.enable = true;

    # Disable DHCP on individual interfaces
    interfaces.enp2s0.useDHCP = false;
    interfaces.enp3s0.useDHCP = false;

    bonds.bond0 = {
      interfaces = ["enp2s0" "enp3s0"];
      driverOptions = {
        miimon = "100";
        mode = "active-backup";
        primary = "enp2s0";
      };
    };

    # Use DHCP
    interfaces.bond0.useDHCP = true;

    hostName = "freezer";
  };
}
