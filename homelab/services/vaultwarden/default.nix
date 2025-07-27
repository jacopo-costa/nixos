{
  config,
  lib,
  pkgs,
  ...
}: let
  service = "vaultwarden";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in {
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    vaultwardenEnvPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the ${service} environment file";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      vaultwarden = {
        image = "vaultwarden/server:latest";
        serviceName = "vaultwarden";
        workdir = "/var/lib/vaultwarden";
        ports = ["80:80" "443:443"];
        environmentFiles = [
          "${cfg.vaultwardenEnvPath}"
        ];
        volumes = [
          "/var/lib/vaultwarden/:/data"
        ];
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.vaultwarden.rule" = "Host(`vault.${homelab.baseDomain}`)";
          "traefik.http.routers.vaultwarden.entrypoints" = "websecure";
          "traefik.http.routers.vaultwarden.tls" = "true";
          "traefik.http.routers.vaultwarden.tls.certResolver" = "cloudflare";
          "traefik.http.routers.vaultwarden.middlewares" = "crowdsec-bouncer@file,ratelimiter@file";
          "traefik.http.services.vaultwarden.loadbalancer.server.port" = "80";
        };
        networks = [
          "traefik"
        ];
      };
    };
  };
}
