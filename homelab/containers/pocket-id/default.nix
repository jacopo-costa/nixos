{
  config,
  lib,
  ...
}: let
  container = "pocket-id";
  cfg = config.homelab.containers.${container};
  homelab = config.homelab;
in {
  options.homelab.containers.${container} = {
    enable = lib.mkEnableOption "Enable pocket-id authentication service";
    pocketIdEnvPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the Pocket ID environment file";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /srv/pocket-id 0755 root root -"
    ];

    virtualisation.oci-containers.containers = {
      pocket-id = {
        image = "ghcr.io/pocket-id/pocket-id:latest";

        dependsOn = [
          "traefik"
        ];

        networks = [
          "traefik"
        ];

        environmentFiles = [
          "${cfg.pocketIdEnvPath}"
        ];

        volumes = [
          "/srv/pocket-id:/app/data"
        ];

        labels = {
          "traefik.enable" = "true";
          "traefik.docker.network" = "traefik";
          "traefik.http.routers.pocket-id.rule" = "Host(`auth.dimoracosta.it`)";
          "traefik.http.routers.pocket-id.entrypoints" = "websecure";
          "traefik.http.services.pocket-id.loadbalancer.server.port" = "1411";
        };

        extraOptions = [
          "--health-cmd=/app/pocket-id healthcheck"
          "--health-interval=90s"
          "--health-timeout=5s"
          "--health-retries=2"
          "--health-start-period=10s"
        ];

        autoStart = true;
      };
    };
  };
}
