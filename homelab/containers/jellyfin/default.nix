{
  config,
  lib,
  ...
}: let
  container = "jellyfin";
  cfg = config.homelab.containers.${container};
  homelab = config.homelab;
in {
  options.homelab.containers.${container} = {
    enable = lib.mkEnableOption "Enable ${container}";
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /srv/${container} 0755 root root -"
    ];

    virtualisation.oci-containers.containers = {
      jellyfin = {
        image = "jellyfin/jellyfin:latest";

        dependsOn = [
          "traefik"
        ];

        networks = [
          "traefik"
        ];

        environment = {
          JELLYFIN_PublishedServerUrl = "https://media.${homelab.baseDomain}";
        };

        volumes = [
          "/srv/jellyfin/config:/config"
          "/srv/jellyfin/cache:/cache"
          "/mnt/tank/arr/media:/arr/media:ro"
        ];

        devices = [
          "/dev/dri/renderD128:/dev/dri/renderD128"
        ];

        labels = {
          "traefik.enable" = "true";
          "traefik.docker.network" = "traefik";
          "traefik.http.routers.jellyfin.rule" = "Host(`media.${homelab.baseDomain}`)";
          "traefik.http.routers.jellyfin.entrypoints" = "websecure";
          "traefik.http.services.jellyfin.loadbalancer.server.port" = "8096";
        };

        extraOptions = [
          "--group-add=303"
        ];

        autoStart = true;
      };
    };
  };
}
