{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.nginx-local;
  homelab = config.homelab;
  svc = config.homelab.services;

  mkVhost = port: {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };
  };
in {
  options.homelab.services.nginx-local = {
    enable = lib.mkEnableOption "Local nginx reverse proxy for LAN access";
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [80];

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;

      virtualHosts =
        lib.mkMerge [
          (lib.mkIf svc.radarr.enable {
            "radarr.${homelab.localDomain}" = mkVhost svc.radarr.port;
          })
          (lib.mkIf svc.sonarr.enable {
            "sonarr.${homelab.localDomain}" = mkVhost svc.sonarr.port;
          })
          (lib.mkIf svc.lidarr.enable {
            "lidarr.${homelab.localDomain}" = mkVhost svc.lidarr.port;
          })
          (lib.mkIf svc.prowlarr.enable {
            "prowlarr.${homelab.localDomain}" = mkVhost svc.prowlarr.port;
          })
          (lib.mkIf svc.bazarr.enable {
            "bazarr.${homelab.localDomain}" = mkVhost svc.bazarr.port;
          })
          (lib.mkIf svc.sabnzbd.enable {
            "sabnzbd.${homelab.localDomain}" = mkVhost svc.sabnzbd.port;
          })
          (lib.mkIf svc.jellyseerr.enable {
            "jellyseerr.${homelab.localDomain}" = mkVhost svc.jellyseerr.port;
          })
          (lib.mkIf svc.flaresolverr.enable {
            "flaresolverr.${homelab.localDomain}" = mkVhost svc.flaresolverr.port;
          })
          (lib.mkIf svc.qbittorrent.enable {
            "qbittorrent.${homelab.localDomain}" = mkVhost svc.qbittorrent.webuiPort;
          })
          (lib.mkIf svc.vaultwarden.enable {
            "vault.${homelab.localDomain}" = mkVhost svc.vaultwarden.port;
          })
          (lib.mkIf svc.immich.enable {
            "photos.${homelab.localDomain}" = mkVhost svc.immich.port;
          })
          (lib.mkIf svc.jellyfin.enable {
            "media.${homelab.localDomain}" = mkVhost svc.jellyfin.port;
          })
          (lib.mkIf svc.nextcloud.enable {
            "cloud.${homelab.localDomain}" = mkVhost svc.nextcloud.port;
          })
          (lib.mkIf svc.pocket-id.enable {
            "auth.${homelab.localDomain}" = mkVhost svc.pocket-id.port;
          })
        ];
    };
  };
}
