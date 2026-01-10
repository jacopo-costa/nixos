{
  config,
  lib,
  pkgs,
  ...
}: let
  container = "immich";
  cfg = config.homelab.containers.${container};
  homelab = config.homelab;
in {
  options.homelab.containers.${container} = {
    enable = lib.mkEnableOption "Enable immich photo manager";
    immichEnvPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the immich environment file";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /srv/${container} 0755 root root -"
    ];

    system.activationScripts.createImmichNet = lib.mkAfter ''
      ${pkgs.podman}/bin/podman network exists immich || ${pkgs.podman}/bin/podman network create immich
    '';

    system.activationScripts.createImmichModelCacheVol = lib.mkAfter ''
      ${pkgs.podman}/bin/podman volume exists immich_model_cache || ${pkgs.podman}/bin/podman volume create immich_model_cache
    '';

    virtualisation.oci-containers.containers = {
      immich_server = {
        image = "ghcr.io/immich-app/immich-server:release";

        dependsOn = [
          "traefik"
          "immich_redis"
          "immich_postgres"
        ];

        networks = [
          "traefik"
          "immich"
        ];

        environmentFiles = [
          "${cfg.immichEnvPath}"
        ];

        volumes = [
          "/mnt/tank/immich:/data"
          "/etc/localtime:/etc/localtime:ro"
        ];

        devices = [
          "/dev/dri/renderD128:/dev/dri/renderD128"
        ];

        labels = {
          "traefik.enable" = "true";
          "traefik.docker.network" = "traefik";
          "traefik.http.routers.immich.rule" = "Host(`photos.${homelab.baseDomain}`)";
          "traefik.http.routers.immich.entrypoints" = "websecure";
          "traefik.http.services.immich.loadbalancer.server.port" = "2283";
        };

        autoStart = true;
      };

      immich_machine_learning = {
        image = "ghcr.io/immich-app/immich-machine-learning:release";

        networks = [
          "immich"
        ];

        environmentFiles = [
          "${cfg.immichEnvPath}"
        ];

        volumes = [
          "immich_model_cache:/cache"
        ];

        autoStart = true;
      };

      immich_redis = {
        image = "docker.io/valkey/valkey:8-bookworm@sha256:fea8b3e67b15729d4bb70589eb03367bab9ad1ee89c876f54327fc7c6e618571";

        networks = [
          "immich"
        ];

        extraOptions = [
          "--health-cmd=redis-cli ping || exit 1"
        ];

        autoStart = true;
      };

      immich_postgres = {
        image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23";

        networks = [
          "immich"
        ];

        environmentFiles = [
          "${cfg.immichEnvPath}"
        ];

        volumes = [
          "/srv/immich/postgres:/var/lib/postgresql/data"
        ];

        autoStart = true;
      };
    };
  };
}
