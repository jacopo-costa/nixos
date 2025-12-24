{
  homelab = {
    enable = true;
    user = "ice";
    group = "ice";
    timeZone = "Europe/Rome";
    baseDomain = "dimoracosta.it";
    services = {
      enable = true;
    };
  };

  virtualisation.libvirtd.allowedBridges = [
    "br0"
  ];
}
