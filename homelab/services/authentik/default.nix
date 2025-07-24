{
  config,
  lib,
  pkgs,
  ...
}: let
  service = "authentik";
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
    environmentFile = lib.mkOption {
      type = lib.types.path;
    };
    emailHost = lib.mkOption {
      description = "The SMTP server address";
      type = lib.types.str;
      default = "smtp.gmail.com";
    };
    emailPort = lib.mkOption {
      description = "The SMTP server port";
      type = lib.types.int;
      default = 587;
    };
    emailUsername = lib.mkOption {
      description = "The SMTP username";
      type = lib.types.str;
      default = "john@example.com";
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      environmentFile = cfg.environmentFile;
      settings = {
        email = {
          host = cfg.emailHost;
          port = cfg.emailHost;
          username = cfg.emailUsername;
          use_tls = true;
          use_ssl = false;
          from = cfg.emailUsername;
        };
        disable_startup_analytics = true;
        avatars = "initials";
      };
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:9000
      '';
    };
  };
}
