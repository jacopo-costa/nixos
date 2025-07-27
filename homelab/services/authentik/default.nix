{
  config,
  pkgs,
  lib,
  ...
}: let
  service = "authentik";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in {
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    authentikEnvPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the ${service} environment file";
    };
  };

  config = lib.mkIf cfg.enable {
    # Create volume if not already existing
    system.activationScripts.createAuthentikVol = {
      text = ''
        ${pkgs.docker}/bin/docker volume inspect authentik-postgres-data >/dev/null 2>&1 || ${pkgs.docker}/bin/docker volume create authentik-postgres-data
        ${pkgs.docker}/bin/docker volume inspect authentik-redis-data >/dev/null 2>&1 || ${pkgs.docker}/bin/docker volume create authentik-redis-data
      '';
    };

    # Create network if not already existing
    system.activationScripts.createAuthentikNet = {
      text = ''
        ${pkgs.docker}/bin/docker network inspect authentik >/dev/null 2>&1 || ${pkgs.docker}/bin/docker network create authentik
      '';
    };

    virtualisation.oci-containers = {
      containers = {
        authentik-postgresql = {
          image = "postgres:16-alpine";
          serviceName = "authentik-postgresql";
          environmentFiles = ["${cfg.authentikEnvPath}"];
          volumes = [
            "authentik-postgres-data:/var/lib/postgresql/data"
          ];
          extraOptions = [
            "--health-cmd=pg_isready -d $$POSTGRES_DB -U $$POSTGRES_USER"
            "--health-interval=30s"
            "--health-timeout=5s"
            "--health-retries=5"
            "--health-start-period=20s"
          ];
          networks = [
            "authentik"
          ];
        };

        authentik-redis = {
          image = "redis:alpine";
          cmd = ["--save" "60" "1" "--loglevel" "warning"];
          volumes = ["authentik-redis-data:/data"];
          extraOptions = [
            "--health-cmd=redis-cli ping | grep PONG"
            "--health-interval=30s"
            "--health-timeout=3s"
            "--health-retries=5"
            "--health-start-period=20s"
          ];
          networks = [
            "authentik"
          ];
        };

        authentik-server = {
          image = "ghcr.io/goauthentik/server:2025.6.4";
          environmentFiles = ["${cfg.authentikEnvPath}"];
          cmd = ["server"];
          volumes = [
            "/var/lib/authentik/media:/media"
            "/var/lib/authentik/templates:/templates"
          ];
          extraOptions = [
            "--label=traefik.enable=true"
            "--label=traefik.docker.network=traefik"
            "--label=traefik.http.routers.authentik.rule=Host(`authentik.${homelab.baseDomain}`)"
            "--label=traefik.http.routers.authentik.entrypoints=websecure"
            "--label=traefik.http.routers.authentik.tls=true"
            "--label=traefik.http.routers.authentik.tls.certResolver=cloudflare"
            "--label=traefik.http.routers.authentik.middlewares=crowdsec-bouncer@file,ratelimiter@file"
            "--label=traefik.http.services.authentik.loadbalancer.server.port=9000"
          ];
          networks = [
            "authentik"
            "traefik"
          ];
          dependsOn = [
            "authentik-postgresql"
            "authentik-redis"
          ];
        };

        authentik-worker = {
          image = "ghcr.io/goauthentik/server:2025.6.4";
          environmentFiles = ["${cfg.authentikEnvPath}"];
          cmd = ["worker"];
          volumes = [
            "/var/run/docker.sock:/var/run/docker.sock"
            "/var/lib/authentik/media:/media"
            "/var/lib/authentik/certs:/certs"
            "/var/lib/authentik/templates:/templates"
          ];
          networks = [
            "authentik"
          ];
          dependsOn = [
            "authentik-postgresql"
            "authentik-redis"
          ];
        };
      };
    };
  };
}
