{...}: {
  homelab = {
    enable = true;
    user = "ice";
    group = "ice";
    intel = true;
  };

  virtualisation.libvirtd.allowedBridges = [
    "br0"
  ];
}
