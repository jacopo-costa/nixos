{config, ...}: let
  hl = config.homelab;
in {
  sops.secrets.nextcloudPass = {};

  homelab = {
    enable = true;
    baseDomain = "dimoracosta.it";
    timeZone = "Europe/Rome";
    services = {
      enable = true;

      # ARR stack
      flaresolverr.enable = true;
      jellyseerr.enable = true;
      prowlarr.enable = true;
      radarr.enable = true;
      sonarr.enable = true;

      # Jellyfin
      jellyfin.enable = true;

      # Deluge
      deluge.enable = true;

      # Nextcloud
      nextcloud = {
        enable = true;
        adminuser = "admin";
        adminpassFile = config.sops.secrets.nextcloudPass.path;
      };

      # Vaultwarden
      vaultwarden.enable = true;
    };
  };
}
