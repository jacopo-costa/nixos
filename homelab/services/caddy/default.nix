{
  config,
  lib,
  pkgs,
  ...
}: let
  service = "caddy";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in {
  options.homelab.services.caddy = {
    enable = lib.mkEnableOption "Enable caddy reverse proxy";
    cloudflareEnvPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the Cloudflare environment file";
    };
  };
  config = lib.mkIf cfg.enable {
    # HTTP & HTTPS ports
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    # ACME certificates service
    security.acme = {
      acceptTerms = true;
      defaults.email = "dimoracosta.system+acme@gmail.com";
      certs.${config.homelab.baseDomain} = {
        reloadServices = ["caddy.service"];
        domain = "${config.homelab.baseDomain}";
        extraDomainNames = ["*.${config.homelab.baseDomain}"];
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        dnsPropagationCheck = true;
        group = config.services.caddy.group;
        environmentFile = "${cfg.cloudflareEnvPath}";
      };
    };

    services.${service} = {
      enable = true;
      globalConfig = ''
        auto_https off
      '';
      virtualHosts = {
        "https://${config.homelab.baseDomain}" = {
          extraConfig = ''
            redir https://{host}{uri}
          '';
        };
        "https://*.${config.homelab.baseDomain}" = {
          extraConfig = ''
            redir https://{host}{uri}
          '';
        };
      };
    };
  };
}
