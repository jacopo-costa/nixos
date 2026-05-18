{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.jellyseerr;
  homelab = config.homelab;
in {
  options.homelab.services.jellyseerr = {
    enable = lib.mkEnableOption {
      description = "Enable Jellyseerr";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "req.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 5055;
    };
  };
  config = lib.mkIf cfg.enable {
    services.jellyseerr = {
      enable = true;
      port = cfg.port;
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };

    # Start Jellyseerr only after caddy
    systemd.services.jellyseerr = {
      after = ["caddy.service"];
      wants = ["caddy.service"];
    };
  };
}
