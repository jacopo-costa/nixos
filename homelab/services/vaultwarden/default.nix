{
  config,
  lib,
  ...
}: let
  service = "vaultwarden";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in {
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    vaultwardenEnvPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the ${service} environment file";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "vault.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8222;
    };
  };

  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      environmentFile = cfg.vaultwardenEnvPath;
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
