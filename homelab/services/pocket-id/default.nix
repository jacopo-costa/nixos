{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  service = "pocket-id";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in {
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "login.${homelab.baseDomain}";
    };
    pocketIdEnvPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the pocket-id environment file";
    };
  };
  config = lib.mkIf cfg.enable {
    # Create network if not already existing
    system.activationScripts.createPocketIdNet = {
      text = ''
        ${pkgs.docker}/bin/docker network inspect pocket-id >/dev/null 2>&1 || ${pkgs.docker}/bin/docker network create pocket-id
      '';
    };

    virtualisation.oci-containers.containers = {
      pocket-id = {
        image = "ghcr.io/pocket-id/pocket-id:v1";
        serviceName = "pocket-id";
        workdir = "/var/lib/pocket-id";
        ports = ["1411:1411"];
        environmentFiles = [
          "${cfg.pocketIdEnvPath}"
        ];
        volumes = [
          "/var/lib/pocket-id/data:/app/data"
        ];
        networks = [
          "pocket-id"
        ];
      };
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:1411
      '';
    };
  };
}
