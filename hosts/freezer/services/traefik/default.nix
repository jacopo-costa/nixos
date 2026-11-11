# Traefik: TLS (Cloudflare wildcard) + the shared middlewares.
# Every app adds its own router under services.traefik.dynamicConfigOptions.http in its own file.
#
# Entrypoints (same as the docker stack):
#   weblocal :80  -> LAN-only apps (*.freezer.lan), no TLS
#   web      :81  -> the router forwards external 80 here, it only redirects to HTTPS
#   websecure :443 -> public apps (*.dimoracosta.it)
{
  config,
  lib,
  ...
}: {
  sops = {
    secrets = {
      "traefik/cfDnsApiToken" = {};
      "traefik/oidcSessionSecret" = {};
      "traefik/oidcClientId" = {};
      "traefik/oidcClientSecret" = {};
      "crowdsec/traefikBouncerKey" = {};
    };

    templates.traefikEnv.content = ''
      CF_DNS_API_TOKEN=${config.sops.placeholder."traefik/cfDnsApiToken"}
      OIDC_SESSION_SECRET=${config.sops.placeholder."traefik/oidcSessionSecret"}
      OIDC_CLIENT_ID=${config.sops.placeholder."traefik/oidcClientId"}
      OIDC_CLIENT_SECRET=${config.sops.placeholder."traefik/oidcClientSecret"}
      CROWDSEC_LAPI_KEY=${config.sops.placeholder."crowdsec/traefikBouncerKey"}
    '';
  };

  networking.firewall.allowedTCPPorts = [80 81 443];

  services.traefik = {
    enable = true;
    environmentFiles = [config.sops.templates.traefikEnv.path];

    staticConfigOptions = {
      global = {
        checkNewVersion = false;
        sendAnonymousUsage = false;
      };

      # Dashboard, routed below on traefik.freezer.lan
      api = {};

      certificatesResolvers.cloudflare.acme = {
        email = config.email.fromAddress;
        storage = "${config.services.traefik.dataDir}/acme.json";
        dnsChallenge = {
          provider = "cloudflare";
          resolvers = ["1.1.1.1:53" "8.8.8.8:53"];
        };
      };

      entryPoints = {
        weblocal = {
          address = ":80";
          http.middlewares = ["lan-only@file"];
        };
        web = {
          address = ":81";
          http.redirections.entryPoint = {
            to = "websecure";
            scheme = "https";
          };
        };
        websecure = {
          address = ":443";
          http = {
            tls = {
              certResolver = "cloudflare";
              domains = [
                {
                  main = "dimoracosta.it";
                  sans = ["*.dimoracosta.it"];
                }
              ];
            };
            middlewares = [
              "security-headers@file"
              "ratelimiter@file"
              "crowdsec-bouncer@file"
            ];
          };
        };
      };

      # Read by crowdsec
      accessLog = {
        filePath = "/var/log/traefik/access.log";
        format = "json";
        filters.statusCodes = ["200-299" "400-599"];
        bufferingSize = 0;
        fields.headers = {
          defaultMode = "drop";
          names.User-Agent = "keep";
        };
      };

      # Downloaded at startup into /var/lib/traefik/plugins-storage
      experimental.plugins = {
        crowdsec-bouncer-traefik-plugin = {
          moduleName = "github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin";
          version = "v1.6.0";
        };
        traefik-oidc-auth = {
          moduleName = "github.com/sevensolutions/traefik-oidc-auth";
          version = "v0.20.1";
        };
      };
    };

    # Secrets are read with {{env `NAME`}}: backticks, because double quotes would break the generated TOML
    dynamicConfigOptions.http = {
      middlewares = {
        # Private client ranges only; Traefik now runs on the host so it sees the real client IP
        lan-only.ipAllowList.sourceRange = ["10.0.0.0/8" "192.168.0.0/16"];

        ratelimiter.rateLimit = {
          average = 500;
          burst = 1000;
        };

        security-headers.headers = {
          stsSeconds = 31536000;
          stsIncludeSubdomains = true;
          stsPreload = true;
          forceSTSHeader = true;
          referrerPolicy = "strict-origin-when-cross-origin";
          contentTypeNosniff = true;
          customFrameOptionsValue = "SAMEORIGIN";
          contentSecurityPolicy = lib.concatStringsSep " " [
            "default-src 'self';"
            "base-uri 'self';"
            "object-src 'none';"
            "frame-ancestors 'none';"
            "script-src 'self' 'unsafe-inline';"
            "style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net;"
            "img-src 'self' data: blob:;"
            "font-src 'self' data:;"
            "connect-src 'self' ws: wss:;"
            "media-src 'self' blob:;"
            "worker-src 'self' blob:;"
            "form-action 'self';"
            "manifest-src 'self';"
          ];
          # Remove server fingerprinting headers
          customResponseHeaders = {
            Server = "";
            X-Powered-By = "";
          };
        };

        crowdsec-bouncer.plugin.crowdsec-bouncer-traefik-plugin = {
          enabled = true;
          defaultDecisionSeconds = 60;
          crowdsecMode = "live";
          crowdsecAppsecEnabled = true;
          crowdsecAppsecHost = "127.0.0.1:7422";
          crowdsecAppsecFailureBlock = true;
          # Blocks everything when crowdsec is down
          crowdsecAppsecUnreachableBlock = true;
          CrowdsecLapiKey = "{{env `CROWDSEC_LAPI_KEY`}}";
          crowdsecLapiHost = "127.0.0.1:8080";
          crowdsecLapiScheme = "http";
          crowdsecLapiTLSInsecureVerify = false;
        };

        # Pocket-ID login for apps without their own (e.g. glance)
        oidc-auth.plugin.traefik-oidc-auth = {
          Secret = "{{env `OIDC_SESSION_SECRET`}}";
          Provider = {
            Url = "https://auth.dimoracosta.it";
            ClientId = "{{env `OIDC_CLIENT_ID`}}";
            ClientSecret = "{{env `OIDC_CLIENT_SECRET`}}";
            UsePkce = true;
          };
          Scopes = ["openid" "profile" "email"];
        };

        # Same, but only the `admins` group. CallbackUri stays under /admin to match the router using it.
        # Register https://vault.dimoracosta.it/admin/oidc/callback in Pocket ID.
        oidc-auth-admins.plugin.traefik-oidc-auth = {
          Secret = "{{env `OIDC_SESSION_SECRET`}}";
          CallbackUri = "/admin/oidc/callback";
          Provider = {
            Url = "https://auth.dimoracosta.it";
            ClientId = "{{env `OIDC_CLIENT_ID`}}";
            ClientSecret = "{{env `OIDC_CLIENT_SECRET`}}";
            UsePkce = true;
          };
          Scopes = ["openid" "profile" "email" "groups"];
          Authorization.AssertClaims = [
            {
              Name = "groups";
              AnyOf = ["admins"];
            }
          ];
        };
      };

      # Dashboard, LAN only
      routers.traefik-dash = {
        rule = "Host(`traefik.freezer.lan`)";
        entryPoints = ["weblocal"];
        service = "api@internal";
      };
    };
  };

  # /var/log/traefik, group-readable so crowdsec (in the traefik group) can read the access log
  systemd.services.traefik.serviceConfig = {
    LogsDirectory = "traefik";
    LogsDirectoryMode = "0750";
  };

  services.logrotate.settings.traefik-access = {
    files = "/var/log/traefik/access.log";
    frequency = "daily";
    rotate = 7;
    compress = true;
    delaycompress = true;
    missingok = true;
    notifempty = true;
    copytruncate = true;
  };
}
