{
  config,
  lib,
  ...
}: let
  service = "traefik";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in {
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    traefikEnvPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the traefik environment file";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."traefik/traefik.yaml".source = ./traefik.yaml;
    environment.etc."traefik/dynamic".source = ./dynamic;
    environment.etc."traefik/catchall".source = ./catchall;

    # Create volume if not already existing
    system.activationScripts.createTraefikLogVol = {
      text = ''
        ${pkgs.docker}/bin/docker volume inspect traefik_logs >/dev/null 2>&1 || ${pkgs.docker}/bin/docker volume create traefik_logs
      '';
    };

    # Create network if not already existing
    system.activationScripts.createTraefikNet = {
      text = ''
        ${pkgs.docker}/bin/docker network inspect traefik >/dev/null 2>&1 || ${pkgs.docker}/bin/docker network create traefik
      '';
    };

    # Traefik container
    virtualisation.oci-containers.containers = {
      traefik = {
        image = "traefik:latest";
        serviceName = "traefik";
        workdir = "/var/lib/traefik";
        ports = ["80:80" "443:443"];
        environmentFiles = [
          "${cfg.traefikEnvPath}"
        ];
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "/etc/traefik/traefik.yaml:/etc/traefik/traefik.yaml:ro"
          "/etc/traefik/dynamic/:/etc/traefik/dynamic/:ro"
          "/var/lib/traefik/certs/:/var/traefik/certs/:rw"
          "traefik_logs:/var/log/traefik"
        ];
        networks = [
          "traefik"
        ];
        extraOptions = [
          "--restart=unless-stopped"
        ];
      };

      catchall = {
        image = "nginx:latest";
        serviceName = "catchall";
        workdir = "/var/lib/traefik/catchall";
        volumes = [
          "/etc/traefik/catchall:/usr/share/nginx/html:ro"
        ];
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.catchall.rule" = "Host(`dimoracosta.it`) || HostRegexp(`.+\\.dimoracosta\\.it`)";
          "traefik.http.routers.catchall.entrypoints" = "websecure";
          "traefik.http.routers.catchall.tls" = "true";
          "traefik.http.routers.catchall.tls.certResolver" = "cloudflare";
          "traefik.http.routers.catchall.priority" = "1";
          "traefik.http.routers.catchall.middlewares" = "crowdsec-bouncer@file,ratelimiter@file";
          "traefik.http.services.catchall.loadbalancer.server.port" = "80";
        };
        networks = [
          "traefik"
        ];
        extraOptions = [
          "--restart=unless-stopped"
        ];
      };
    };
  };
}
