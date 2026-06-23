{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.jellyfin;
  homelab = config.homelab;
in {
  options.homelab.services.jellyfin = {
    enable = lib.mkEnableOption "Jellyfin media server";
    url = lib.mkOption {
      type = lib.types.str;
      default = "media.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8096;
    };
  };

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      group = homelab.group;
    };

    # Required for VA-API hardware transcoding
    users.users.${homelab.user}.extraGroups = ["render" "video"];

    systemd.services.jellyfin = {
      environment = {
        JELLYFIN_PublishedServerUrl = "https://${cfg.url}";
      };
    };
  };
}
