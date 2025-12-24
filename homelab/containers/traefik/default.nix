{
  config,
  lib,
  ...
}: let
  container = "traefik";
  cfg = config.homelab.containers.${container};
  homelab = config.homelab;
in {
  options.homelab.containers.${container} = {
    enable = lib.mkEnableOption "Enable traefik reverse proxy";
    cloudflareEnvPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the Cloudflare environment file";
    };
  };
  config = lib.mkIf cfg.enable {
    system.activationScripts.createTraefikNet = lib.mkAfter ''
      podman network exists traefik || podman network create traefik
    '';

    system.activationScripts.createTraefikLogVol = lib.mkAfter ''
      podman volume exists traefik_logs || podman volume create traefik_logs
    '';

    virtualisation.oci-containers.containers = {
      traefik = {
        image = "traefik:latest";

        networks = [
          "traefik"
        ];
        ports = [
          "80:80"
          "443:443"
        ];

        environmentFiles = [
          "${cfg.cloudflareEnvPath}"
        ];

        volumes = [
          "/run/podman/podman.sock:/var/run/docker.sock:z"
          "/srv/traefik/traefik.yaml:/etc/traefik/traefik.yaml:ro"
          "/srv/traefik/dynamic/:/etc/traefik/dynamic/:ro"
          "/srv/traefik/data/certs/:/var/traefik/certs/:rw"
          "traefik_logs:/var/log/traefik"
        ];

        autoStart = true;
      };
    };
  };
}
