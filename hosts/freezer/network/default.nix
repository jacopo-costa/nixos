{
  networking = {
    hostId = "f028eb6b";
    hostName = "freezer";

    defaultGateway = "192.168.30.1";
    nameservers = ["192.168.30.1"];

    bridges.br0.interfaces = ["enp3s0"];
    interfaces.br0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          "address" = "192.168.30.2";
          "prefixLength" = 29;
        }
      ];
    };
  };
}
