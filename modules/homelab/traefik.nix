{config, ...}: {
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

      certificatesResolvers.cloudflare.acme = {
        email = "costa.jacopo@gmail.com";
        storage = "${config.services.traefik.dataDir}/acme.json";
        dnsChallenge = {
          provider = "cloudflare";
          resolvers = [
            "1.1.1.1:53"
            "1.0.0.1:53"
          ];
        };
        propagation.delayBeforeChecks = 60;
      };
    };

    dynamicConfigOptions = {
      http.routers = {
        haos = {
          rule = "Host(`vault.dimoracosta.it`)";
          service = "vaultwarden";
          tls.certresolver = "cloudflare";
        };
      };

      http.services = {
        vaultwarden = {
          loadBalancer.servers = ["http://127.0.0.1:8222"];
        };
      };
    };
  };
}
