{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  service = "pocket-id";
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
    pocketIdEnvPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the pocket-id environment file";
    };
  };
  config = lib.mkIf cfg.enable {
    services.pocket-id = {
      enable = true;
      environmentFile = cfg.pocketIdEnvPath;
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:1411
      '';
    };
  };
}
