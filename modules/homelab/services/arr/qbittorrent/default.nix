{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homelab.services.qbittorrent;
  homelab = config.homelab;
in {
  options.homelab.services.qbittorrent = {
    enable = lib.mkEnableOption "qBittorrent torrent client via Gluetun VPN";
    gluetunEnvPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to Gluetun environment file containing Mullvad WireGuard credentials";
    };
    webuiPort = lib.mkOption {
      type = lib.types.port;
      default = 8090;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.create-arr-network = {
      description = "Create arr Docker network";
      after = ["docker.service"];
      requires = ["docker.service"];
      before = ["docker-gluetun.service"];
      wantedBy = ["docker-gluetun.service"];
      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.docker}/bin/docker network inspect arr > /dev/null 2>&1 || ${pkgs.docker}/bin/docker network create arr
      '';
    };

    virtualisation.oci-containers.containers = {
      gluetun = {
        image = "qmcgaw/gluetun:v3";
        # Exposes qbittorrent WebUI since qbittorrent shares this network namespace
        ports = ["127.0.0.1:${toString cfg.webuiPort}:${toString cfg.webuiPort}"];
        environmentFiles = [cfg.gluetunEnvPath];
        environment = {
          VPN_SERVICE_PROVIDER = "mullvad";
          VPN_TYPE = "wireguard";
          TZ = homelab.timeZone;
          SERVER_COUNTRIES = "Italy,France,Germany,Switzerland,Spain,Netherlands,Austria,Belgium";
        };
        volumes = ["/var/lib/gluetun:/gluetun"];
        networks = ["arr"];
        devices = ["/dev/net/tun:/dev/net/tun"];
        capabilities = {
          NET_ADMIN = true;
        };
      };

      qbittorrent = {
        image = "linuxserver/qbittorrent:5.2.2";
        environment = {
          PUID = toString config.users.users.${homelab.user}.uid;
          PGID = toString config.users.groups.${homelab.group}.gid;
          TZ = homelab.timeZone;
          WEBUI_PORT = toString cfg.webuiPort;
          TORRENTING_PORT = "6881";
        };
        volumes = [
          "/var/lib/qbittorrent:/config"
          "/mnt/tank/arr/torrents:/arr/torrents"
        ];
        # Share gluetun's network namespace for VPN killswitch
        extraOptions = ["--network=container:gluetun"];
        dependsOn = ["gluetun"];
      };
    };
  };
}
