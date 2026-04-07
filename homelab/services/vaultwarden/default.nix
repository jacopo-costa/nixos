{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.vaultwarden;
  homelab = config.homelab;
in {
  options.homelab.services.vaultwarden = {
    enable = lib.mkEnableOption {
      description = "Enable Vaultwarden";
    };
    vaultwardenEnvPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the Vaultwarden environment file";
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
    services.vaultwarden = {
      enable = true;
      environmentFile = cfg.vaultwardenEnvPath;
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      extraConfig = ''
        import cloudflare_tls
        import security_headers
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
