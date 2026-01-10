{
  config,
  lib,
  ...
}: let
  container = "vaultwarden";
  cfg = config.homelab.containers.${container};
  homelab = config.homelab;
in {
  options.homelab.containers.${container} = {
    enable = lib.mkEnableOption "Enable vaultwarden password manager";
    vaultwardenEnvPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the vaultwarden environment file";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /srv/vaultwarden 0755 root root -"
    ];

    virtualisation.oci-containers.containers = {
      vaultwarden = {
        image = "vaultwarden/server:latest";

        dependsOn = [
          "traefik"
        ];

        networks = [
          "traefik"
        ];

        environmentFiles = [
          "${cfg.vaultwardenEnvPath}"
        ];

        volumes = [
          "/srv/vaultwarden:/data"
        ];

        labels = {
          "traefik.enable" = "true";
          "traefik.docker.network" = "traefik";
          "traefik.http.routers.vaultwarden.rule" = "Host(`vault.dimoracosta.it`)";
          "traefik.http.routers.vaultwarden.entrypoints" = "websecure";
          "traefik.http.services.vaultwarden.loadbalancer.server.port" = "80";
        };

        autoStart = true;
      };
    };
  };
}
