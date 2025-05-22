{config, ...}: {
  # Networking
  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };
}
