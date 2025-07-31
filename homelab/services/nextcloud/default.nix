{
  config,
  pkgs,
  lib,
  ...
}: let
  service = "nextcloud";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in {
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "cloud.${homelab.baseDomain}";
    };
  };
  config = lib.mkIf cfg.enable {
    # Create volume if not already existing
    system.activationScripts.createNextcloudVol = {
      text = ''
        ${pkgs.docker}/bin/docker volume inspect nextcloud_aio_mastercontainer >/dev/null 2>&1 || ${pkgs.docker}/bin/docker volume create nextcloud_aio_mastercontainer
      '';
    };

    virtualisation.oci-containers.containers = {
      nextcloud-aio-mastercontainer = {
        image = "ghcr.io/nextcloud-releases/all-in-one:latest";
        serviceName = "nextcloud-aio-mastercontainer";
        workdir = "/var/lib/nextcloud";
        ports = ["8080:8080"];
        environment = {
          APACHE_PORT = "11000";
          APACHE_IP_BINDING = "0.0.0.0";
          SKIP_DOMAIN_VALIDATION = false;
          NEXTCLOUD_DATADIR = "/tank/nextcloud";
          NEXTCLOUD_ENABLE_DRI_DEVICE = true;
        };
        volumes = [
          "nextcloud_aio_mastercontainer:/mnt/docker-aio-config"
          "/var/run/docker.sock:/var/run/docker.sock:ro"
        ];
        extraOptions = [
          "--init"
        ];
      };
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:11000
      '';
    };
  };
}
