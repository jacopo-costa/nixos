{
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
      default = "login.${homelab.baseDomain}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.${service};
      settings.TRUST_PROXY = true;
      settings.APP_URL = "https://${cfg.url}";
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:1411
      '';
    };
  };
}
