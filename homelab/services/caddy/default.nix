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

    # TODO: Rewrite the script to add the bouncer with the secret api key automatically
    # Register the Caddy bouncer API key on CrowdSec startup
    # This avoids hardcoding keys — the key file is generated once and reused
    # systemd.services.crowdsec.serviceConfig.ExecStartPre = let
    #   script = pkgs.writeScriptBin "register-caddy-bouncer" ''
    #     #!${pkgs.runtimeShell}
    #     set -eu
    #     if ! cscli bouncers list | grep -q "caddy-bouncer"; then
    #       cscli bouncers add "caddy-bouncer" --key "$(cat /run/secrets/crowdsecBouncerKey)"
    #     fi
    #   '';
    # in ["${script}/bin/register-caddy-bouncer"];

    # To allow the write on the file /var/lib/crowdsec/lapi-credentials.yaml
    systemd.tmpfiles.rules = ["d /var/lib/crowdsec 0755 ${config.services.crowdsec.user} ${config.services.crowdsec.group}"];

    # To allow crowdsec to read the access.log of caddy
    users.users.${config.services.crowdsec.user}.extraGroups = [
      config.services.caddy.group
    ];

    # Start caddy only after crowdsec
    systemd.services.caddy = {
      after = ["crowdsec.service"];
      wants = ["crowdsec.service"];
    };

    services = {
      crowdsec = {
        enable = true;

        settings = {
          lapi.credentialsFile = "/var/lib/crowdsec/lapi-credentials.yaml";

          general = {
            api.server = {
              enable = true;
              listen_uri = "127.0.0.1:8080";
            };
          };
        };

        # Install relevant detection scenarios
        hub = {
          collections = [
            "crowdsecurity/caddy" # Caddy-specific scenarios
            "crowdsecurity/linux" # SSH, base linux scenarios
            "crowdsecurity/http-cve" # Known HTTP CVEs
          ];
        };

        localConfig = {
          # Parse Caddy access logs
          acquisitions = [
            {
              source = "file";
              filenames = ["/var/log/caddy/access.log"];
              labels.type = "caddy";
            }
            # Also monitor SSH brute force attempts
            {
              source = "journalctl";
              journalctl_filter = ["_SYSTEMD_UNIT=sshd.service"];
              labels.type = "syslog";
            }
          ];
        };

        # Auto-update hub definitions daily
        autoUpdateService = true;
      };

      caddy = {
        enable = true;

        logDir = "/var/log/caddy";
        logFormat = ''
          output file /var/log/caddy/access.log
          format json
          level INFO
        '';

        package = pkgs.caddy.withPlugins {
          plugins = [
            "github.com/caddy-dns/cloudflare@v0.2.4"
            "github.com/hslatman/caddy-crowdsec-bouncer@v0.11.0"
          ];
          hash = "sha256-2QRJs2wHlYz+hLuB0v5a+iGWd34Yihwt/uPwqBBFEAo=";
        };

        # Load the Cloudflare token into Caddy's environment
        environmentFile = cfg.cloudflareEnvPath;

        email = "dimoracosta.system@gmail.com";

        globalConfig = ''
          acme_dns cloudflare {$CF_DNS_API_TOKEN}
          # acme_ca https://acme-v02.api.letsencrypt.org/directory
          acme_ca https://acme-staging-v02.api.letsencrypt.org/directory

          admin off

          # Wire up CrowdSec — points to the Local API
          crowdsec {
            api_url http://127.0.0.1:8080
            api_key {$CROWDSEC_BOUNCER_KEY}
            # Use stream mode (polls periodically) rather than checking every request
            ticker_interval 15s
          }
        '';

        extraConfig = ''
          (security_headers) {
            header {
              # Prevent MIME type sniffing
              X-Content-Type-Options "nosniff"
              # Force HTTPS
              Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
              # Control referrer information
              Referrer-Policy "strict-origin-when-cross-origin"
              # Disable FLoC/interest-cohort tracking
              Permissions-Policy "interest-cohort=()"
              # Remove server identity headers
              -Server
              -X-Powered-By
            }
          }

          # Snippet to apply CrowdSec blocking on a route
          (crowdsec_protected) {
            route {
              crowdsec
              import security_headers
            }
          }
        '';

        virtualHosts = {
          "*.${homelab.baseDomain}".extraConfig = ''
            tls {
              dns cloudflare {$CF_DNS_API_TOKEN}
              resolvers 1.1.1.1
            }
          '';

          "${homelab.baseDomain}".extraConfig = ''
            tls {
              dns cloudflare {$CF_DNS_API_TOKEN}
              resolvers 1.1.1.1
            }
          '';
        };
      };
    };
  };
}
