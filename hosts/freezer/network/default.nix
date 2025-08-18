{...}: {
  # Networking
  networking = {
    useNetworkd = true;
    networkmanager.enable = false;

    hostId = "f028eb6b";
    hostName = "freezer";
  };

  systemd.network = {
    netdevs = {
      "10-bond0" = {
        netdevConfig = {
          Name = "bond0";
          Kind = "bond";
        };
        bondConfig = {
          Mode = "active-backup";
          MIIMonitorSec = "100ms";
        };
      };
    };

    networks = {
      "30-enp3s0" = {
        matchConfig.Name = "enp3s0";
        networkConfig.Bond = "bond0";
      };

      "30-enp4s0" = {
        matchConfig.Name = "enp4s0";
        networkConfig.Bond = "bond0";
      };

      "40-bond0" = {
        matchConfig.Name = "bond0";
        linkConfig.RequiredForOnline = "carrier";
        networkConfig = {
          DHCP = "no";
          Address = ["192.168.30.2/29"];
          Gateway = ["192.168.30.1"];
          DNS = ["192.168.30.1"];
        };
      };
    };

    links = {
      "30-enp3s0" = {
        linkConfig = {
          WakeOnLan = "magic";
        };
      };

      "30-enp4s0" = {
        linkConfig = {
          WakeOnLan = "magic";
        };
      };
    };
  };
}
