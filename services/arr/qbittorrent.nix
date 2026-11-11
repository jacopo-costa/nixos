# qBittorrent behind the gluetun VPN (Mullvad WireGuard), both as podman containers.
# qBittorrent shares gluetun's network: if the VPN is down it has no network at all (kill switch).
# Data: /var/lib/gluetun, /var/lib/qbittorrent
{config, ...}: {
  sops = {
    secrets = {
      "gluetun/wireguardPrivateKey" = {};
      "gluetun/wireguardAddresses" = {};
    };

    templates.gluetunEnv.content = ''
      WIREGUARD_PRIVATE_KEY=${config.sops.placeholder."gluetun/wireguardPrivateKey"}
      WIREGUARD_ADDRESSES=${config.sops.placeholder."gluetun/wireguardAddresses"}
    '';
  };

  virtualisation.oci-containers.containers = {
    gluetun = {
      image = "qmcgaw/gluetun:latest";
      # qBittorrent's web UI, reachable through gluetun's network
      ports = ["127.0.0.1:8090:8090"];
      environmentFiles = [config.sops.templates.gluetunEnv.path];
      environment = {
        VPN_SERVICE_PROVIDER = "mullvad";
        VPN_TYPE = "wireguard";
        TZ = config.time.timeZone;
        SERVER_COUNTRIES = "Italy,France,Germany,Switzerland,Spain,Netherlands,Austria,Belgium";
      };
      volumes = ["/var/lib/gluetun:/gluetun"];
      devices = ["/dev/net/tun:/dev/net/tun"];
      capabilities.NET_ADMIN = true;
    };

    qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      dependsOn = ["gluetun"];
      networks = ["container:gluetun"];
      environment = {
        PUID = toString config.users.users.${config.homelab.user}.uid;
        PGID = toString config.users.groups.${config.homelab.group}.gid;
        TZ = config.time.timeZone;
        WEBUI_PORT = "8090";
        TORRENTING_PORT = "6881";
      };
      volumes = [
        "/var/lib/qbittorrent:/config"
        # Same path as in docker so the saved torrent locations stay valid
        "/mnt/tank/arr/torrents:/arr/torrents"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/gluetun 0700 root root -"
    "d /var/lib/qbittorrent 0750 ${config.homelab.user} ${config.homelab.group} -"
  ];

  # Torrents live on the pool: never start without it
  systemd.services.podman-qbittorrent = {
    requires = ["zfs-import-tank.service"];
    after = ["zfs-import-tank.service" "zfs-mount.service"];
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.qbittorrent = {
      rule = "Host(`qbittorrent.freezer.lan`)";
      entryPoints = ["weblocal"];
      service = "qbittorrent";
    };
    services.qbittorrent.loadBalancer.servers = [{url = "http://127.0.0.1:8090";}];
  };
}
