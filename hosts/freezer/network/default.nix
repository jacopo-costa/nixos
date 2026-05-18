{
  networking = {
    useNetworkd = true;
    useDHCP = false;

    hostId = "f028eb6b";
    hostName = "freezer";

    nameservers = ["192.168.30.1"];
  };

  systemd.network = {
    enable = true;

    # Bridge device
    netdevs."10-br0" = {
      netdevConfig = {
        Name = "br0";
        Kind = "bridge";
      };
    };

    networks = {
      # Physical NIC enslaved to the bridge
      "20-enp3s0" = {
        matchConfig.Name = "enp3s0";
        networkConfig.Bridge = "br0";
        linkConfig.RequiredForOnline = "enslaved";
      };

      # Bridge carries the host IP
      "30-br0" = {
        matchConfig.Name = "br0";
        linkConfig.RequiredForOnline = "routable";
        networkConfig = {
          DHCP = "no";
          Address = "192.168.30.2/29";
          Gateway = "192.168.30.1";
          IPv6AcceptRA = false;
        };
      };
    };
  };
}
