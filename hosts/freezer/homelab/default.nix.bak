{config, ...}: let
  homelab = config.homelab;
in {
  homelab = {
    enable = true;
    user = "ice";
    group = "ice";
    timeZone = "Europe/Rome";
    baseDomain = "dimoracosta.it";
    containers.enable = true;
  };

  virtualisation.libvirtd.allowedBridges = [
    "br0"
  ];
}
