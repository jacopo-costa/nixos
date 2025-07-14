{
  config,
  pkgs,
  ...
}: {
  networking.firewall.allowedTCPPorts = [80 443];

  sops = {
    # Cloudflare Token
    secrets."cloudflareToken" = {};

    templates.cloudflareEnv = {
      content = ''
        CF_DNS_API_TOKEN=${config.sops.placeholder.cloudflareToken}
      '';
      path = "${config.services.traefik.dataDir}/env";
    };
  };

  services.traefik = {
    enable = true;

    environmentFiles = ["${config.services.traefik.dataDir}/env"];

    staticConfigOptions = {
      global = {
        checkNewVersion = false;
        sendAnonymousUsage = false;
      };

      entryPoints = {
        web = {
          address = ":80";
          asDefault = true;
          http.redirections.entrypoint = {
            to = "websecure";
            scheme = "https";
          };
        };

        websecure = {
          address = ":443";
          asDefault = true;
          http.tls.certResolver = "cloudflare";
        };
      };

      log = {
        level = "INFO";
        filePath = "${config.services.traefik.dataDir}/traefik.log";
      };

      accesslog = {
        filePath = "${config.services.traefik.dataDir}/access.log";
      };

      certificatesResolvers.cloudflare.acme = {
        email = "dimoracosta.system@gmail.com";
        storage = "${config.services.traefik.dataDir}/acme.json";
        dnsChallenge = {
          provider = "cloudflare";
          resolvers = [
            "1.1.1.1:53"
            "1.0.0.1:53"
          ];
        };
      };
    };

    dynamicConfigOptions = {
      http.middlewares = {
        ratelimiter.rateLimit = {
          average = 50;
          burst = 100;
        };
        security-headers.headers.customResponseHeaders = {
          Strict-Transport-Security = "max-age=31536000; includeSubDomains; preload";
          Content-Security-Policy = "default-src 'self'; script-src 'self' 'unsafe-inline'; object-src 'none';";
          X-Content-Type-Options = "nosniff";
          X-Frame-Options = "DENY";
          X-XSS-Protection = "1; mode=block";
          Referrer-Policy = "no-referrer-when-downgrade";
          Cache-Control = "no-store, no-cache, must-revalidate";
        };
        nextcloud-secure-headers.headers = {
          hostsProxyHeaders = [
            "X-Forwarded-Host"
          ];
          referrerPolicy = "same-origin";
        };
      };

      http.routers = {
        vaultwarden = {
          rule = "Host(`vault.dimoracosta.it`)";
          service = "vaultwarden";
          tls.certresolver = "cloudflare";
          middlewares = [
            "ratelimiter"
          ];
        };

        jellyfin = {
          rule = "Host(`jellyfin.dimoracosta.it`)";
          service = "jellyfin";
          tls.certresolver = "cloudflare";
        };

        jellyseerr = {
          rule = "Host(`jellyseerr.dimoracosta.it`)";
          service = "jellyseerr";
          tls.certresolver = "cloudflare";
        };

        nextcloud = {
          rule = "Host(`cloud.dimoracosta.it`)";
          service = "nextcloud";
          tls.certresolver = "cloudflare";
          middlewares = [
            "nextcloud-secure-headers"
          ];
        };

        pocketid = {
          rule = "Host(`pocketid.dimoracosta.it`)";
          service = "pocketid";
          tls.certresolver = "cloudflare";
          middlewares = [
            "ratelimiter"
          ];
        };
      };

      http.services = {
        vaultwarden.loadBalancer.servers = [
          {
            url = "http://127.0.0.1:8222";
          }
        ];

        jellyfin.loadBalancer.servers = [
          {
            url = "http://127.0.0.1:8096";
          }
        ];

        jellyseerr.loadBalancer.servers = [
          {
            url = "http://127.0.0.1:5055";
          }
        ];

        nextcloud.loadBalancer.servers = [
          {
            url = "http://127.0.0.1:11000";
          }
        ];

        pocketid.loadBalancer.servers = [
          {
            url = "http://127.0.0.1:1411";
          }
        ];
      };
    };
  };
}
