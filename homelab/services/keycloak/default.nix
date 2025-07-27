{
  config,
  lib,
  pkgs,
  ...
}: let
  service = "keycloak";
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
    port = lib.mkOption {
      type = lib.types.port;
      default = 8821;
    };
    keycloakDbPassFile = lib.mkOption {
      type = lib.types.path;
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      initialAdminPassword = "dumbo";
      database.passwordFile = cfg.keycloakDbPassFile;
      settings = {
        http-port = cfg.port;
        hostname = cfg.url;
        hostname-strict = false;
        hostname-strict-https = false;
        proxy-headers = "xforwarded";
        http-enabled = true;
      };
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
