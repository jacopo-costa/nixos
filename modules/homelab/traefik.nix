{
  config,
  pkgs,
  ...
}: {
  networking.firewall.allowedTCPPorts = [80 443];

  sops = {
    # Cloudflare Token
    secrets."cloudflareToken" = {};

    # Crowdsec bouncer API key
    secrets."crowdsecTraefikBouncerKey" = {};

    templates.cloudflareEnv = {
      content = ''
        CF_DNS_API_TOKEN=${config.sops.placeholder.cloudflareToken}
      '';
      path = "${config.services.traefik.dataDir}/env";
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      crowdsec = {
        image = "crowdsecurity/crowdsec:latest";
        environment = {
          COLLECTIONS = "crowdsecurity/linux crowdsecurity/traefik crowdsecurity/appsec-virtual-patching crowdsecurity/appsec-generic-rules";
        };
        volumes = [
          "/etc/crowdsec:/etc/crowdsec"
          "/var/lib/traefik/access.log:/var/log/traefik/access.log:ro"
          "/var/lib/traefik/traefik.log:/var/log/traefik/traefik.log:ro"
        ];
      };
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

      experimental.plugins = {
        crowdsec-bouncer = {
          moduleName = "github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin";
          version = "v1.4.4";
        };
      };
    };

    dynamicConfigOptions = {
      http.middlewares = {
        ratelimiter.rateLimit = {
          average = 50;
          burst = 100;
        };

        crowdsec-bouncer.plugin.crowdsec-bouncer-traefik-plugin = {
          enabled = true;
          crowdsecLapiKey = "${config.sops.placeholder.crowdsecTraefikBouncerKey}";
          crowdsecAppsecEnabled = true;
          crowdsecAppsecHost = "127.0.0.1:7422";
          crowdsecAppsecFailureBlock = true;
          crowdsecAppsecUnreachableBlock = true;
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
      };
    };
  };
}
