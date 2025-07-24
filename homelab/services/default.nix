{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homelab.services;
in {
  imports = [
    ./arr/flaresolverr
    ./arr/jellyseerr
    ./arr/prowlarr
    ./arr/radarr
    ./arr/sonarr
    ./deluge
    ./jellyfin
    ./authentik
    ./nextcloud
    ./vaultwarden
  ];

  # Options
  options.homelab.services = {
    enable = lib.mkEnableOption "Settings and services for the homelab";
    cloudflareEnvPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the Cloudflare environment file";
    };
  };

  config = lib.mkIf config.homelab.services.enable {
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

    # Caddy, redir every domain to its counterpart in HTTPS
    services.caddy = {
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

    # Setup podman for containerization
    virtualisation.podman = {
      dockerCompat = true;
      autoPrune.enable = true;
      extraPackages = [pkgs.zfs];
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };
    virtualisation.oci-containers = {
      backend = "podman";
    };

    networking.firewall.interfaces.podman0.allowedUDPPorts =
      lib.lists.optionals config.virtualisation.podman.enable
      [53];
  };
}
