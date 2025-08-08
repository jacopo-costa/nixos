{
  config,
  lib,
  ...
}: let
  service = "onlyoffice";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in {
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "office.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8057;
    };
    onlyofficeJwtSecretPath = lib.mkOption {
      type = lib.types.path;
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      hostname = "onlyoffice";
      port = cfg.port;
      jwtSecretFile = cfg.onlyofficeJwtSecretPath;
    };

    services.nginx = {
      virtualHosts."${config.services.onlyoffice.hostname}" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = cfg.port;
          }
        ];
      };
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port} {
          # Required to circumvent bug of Onlyoffice loading mixed non-https content
          header_up X-Forwarded-Proto https
        }
      '';
    };
  };
}
