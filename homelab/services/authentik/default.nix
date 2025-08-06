{
  config,
  lib,
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
      default = "auth.${homelab.baseDomain}";
    };
    authentikEnvPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the authentik environment file";
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      environmentFile = cfg.authentikEnvPath;
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:9000
      '';
    };
  };
}
