{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homelab.services.caddy;
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

    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = ["github.com/caddy-dns/cloudflare@v0.2.4"];
        hash = lib.fakeHash;
      };

      # Load the Cloudflare token into Caddy's environment
      environmentFiles = [cfg.cloudflareEnvPath];

      globalConfig = lib.mkAfter ''
        email dimoracosta.system@gmail.com

        (cloudflare_tls) {
          tls {
            dns cloudflare {env.CLOUDFLARE_API_TOKEN}
            resolvers 1.1.1.1
          }
        }

        (security_headers) {
          header {
            # Prevent clickjacking
            X-Frame-Options "SAMEORIGIN"
            # Prevent MIME type sniffing
            X-Content-Type-Options "nosniff"
            # Force HTTPS
            Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
            # Control referrer information
            Referrer-Policy "strict-origin-when-cross-origin"
            # Disable FLoC/interest-cohort tracking
            Permissions-Policy "interest-cohort=()"
            # Basic CSP — tighten per-service as needed
            Content-Security-Policy "default-src 'self'; script-src 'self'; object-src 'none'"
            # Remove server identity headers
            -Server
            -X-Powered-By
          }
        }
      '';
    };
  };
}
