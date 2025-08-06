{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homelab.services;
in {
  imports = [
    ./arr/flaresolverr
    ./arr/jellyseerr
    ./arr/prowlarr
    ./arr/radarr
    ./arr/sonarr
    ./authentik
    ./caddy
    ./deluge
    ./immich
    ./jellyfin
    ./nextcloud
    ./paperless
    ./vaultwarden
  ];

  # Options
  options.homelab.services = {
    containerization = lib.mkEnableOption "Enable containerization for the homelab";
    containerizationType = lib.mkOption {
      type = with lib.types; nullOr (enum ["docker" "podman"]);
      default = "docker";
      description = "Type of containerization to use (docker or podman)";
    };
  };

  config = lib.mkIf cfg.containerization {
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
