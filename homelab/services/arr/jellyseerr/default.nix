{
  pkgs,
  config,
  lib,
  ...
}: let
  service = "jellyseerr";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in {
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 5055;
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      port = cfg.port;
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
