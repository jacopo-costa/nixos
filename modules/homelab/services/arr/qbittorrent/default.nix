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
    # Create the arr Docker network before gluetun starts
    systemd.services.docker-network-arr = {
      description = "Create arr Docker network";
      after = ["docker.service"];
      requires = ["docker.service"];
      before = ["docker-gluetun.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.docker}/bin/docker network create --driver bridge arr || true";
      };
    };

    virtualisation.oci-containers.containers = {
      gluetun = {
        image = "qmcgaw/gluetun:v3";
        # Exposes qbittorrent WebUI since qbittorrent shares this network namespace
        ports = ["${toString cfg.webuiPort}:${toString cfg.webuiPort}"];
        environmentFiles = [cfg.gluetunEnvPath];
        environment = {
          VPN_SERVICE_PROVIDER = "mullvad";
          VPN_TYPE = "wireguard";
          TZ = homelab.timeZone;
          SERVER_COUNTRIES = "Italy,France,Germany,Switzerland,Spain,Netherlands,Austria,Belgium";
        };
        volumes = ["/var/lib/gluetun:/gluetun"];
        extraOptions = [
          "--network=arr"
          "--cap-add=NET_ADMIN"
          "--device=/dev/net/tun:/dev/net/tun"
        ];
      };

      qbittorrent = {
        image = "lscr.io/linuxserver/qbittorrent:latest";
        environment = {
          PUID = "950";
          PGID = "950";
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
