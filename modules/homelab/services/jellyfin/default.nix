{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.jellyfin;
  homelab = config.homelab;
in {
  options.homelab.services.jellyfin = {
    enable = lib.mkEnableOption {
      description = "Enable Jellyfin";
    };
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
      user = homelab.user;
      group = homelab.group;
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
