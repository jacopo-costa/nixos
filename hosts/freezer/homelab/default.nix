{config, ...}: let
  hl = config.homelab;
in {
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

      # Vaultwarden
      vaultwarden.enable = true;
    };
  };
}
