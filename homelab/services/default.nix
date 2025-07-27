{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homelab.services;
in {
  imports = [
    ./caddy
    ./arr/flaresolverr
    ./arr/jellyseerr
    ./arr/prowlarr
    ./arr/radarr
    ./arr/sonarr
    ./deluge
    ./jellyfin
    ./keycloak
    ./vaultwarden
  ];

  # Options
  options.homelab.services = {
    enable = lib.mkEnableOption "Settings and services for the homelab";
    containerizationType = lib.mkOption {
      type = with lib.types; nullOr (enum ["docker" "podman"]);
      default = "docker";
      description = "Type of containerization to use (docker or podman)";
    };
  };

  config = lib.mkIf config.homelab.services.enable {
    # Setup containerization
    virtualisation.${cfg.containerizationType} = {
      enable = true;
      autoPrune.enable = true;
    };

    virtualisation.oci-containers = {
      backend = cfg.containerizationType;
    };
  };
}
