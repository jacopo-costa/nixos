{...}: {
  homelab = {
    enable = true;
    user = "ice";
    group = "ice";
  };

  virtualisation.libvirtd.allowedBridges = [
    "br0"
  ];
}
