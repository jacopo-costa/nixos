{config, ...}: {
  # Networking
  networking = {
    useNetworkd = true;
    networkmanager.enable = false;

    firewall = {
      enable = true;
    };

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
          DHCP = "yes";
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
