{
  config,
  lib,
  pkgs,
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
    system.activationScripts.createTraefikLogVol = lib.mkAfter ''
      ${pkgs.podman}/bin/podman volume exists traefik_logs || ${pkgs.podman}/bin/podman volume create traefik_logs
    '';

    systemd.tmpfiles.rules = [
      "d /srv/${container}/config/dynamic 0755 root root -"
      "d /srv/${container}/config/data/certs 0755 root root -"
    ];

    virtualisation.oci-containers.containers = {
      ${container} = {
        image = "traefik:latest";

        dependsOn = [
          "crowdsec"
        ];

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
          "/srv/traefik/config/traefik.yaml:/etc/traefik/traefik.yaml:ro"
          "/srv/traefik/config/dynamic/:/etc/traefik/dynamic/:ro"
          "/srv/traefik/data/certs/:/var/traefik/certs/:rw"
          "traefik_logs:/var/log/traefik"
        ];

        autoStart = true;
      };
    };
  };
}
