# Komga: comics/manga server, login with Pocket-ID. Data: /var/lib/komga
# Libraries: /data (the old komga_data volume, now /var/lib/komga/data) and /opt/suwayomi (Suwayomi downloads)
{config, ...}: {
  sops = {
    secrets = {
      "komga/oidcClientId" = {};
      "komga/oidcClientSecret" = {};
    };

    templates.komgaEnv.content = ''
      SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_POCKETID_CLIENTID=${config.sops.placeholder."komga/oidcClientId"}
      SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_POCKETID_CLIENTSECRET=${config.sops.placeholder."komga/oidcClientSecret"}
    '';
  };

  services.komga = {
    enable = true;
    settings = {
      server.port = 25600;

      komga = {
        oauth2-account-creation = true;
        oidc-email-verification = true;
      };

      # Pocket-ID login (client id/secret come from the env file above)
      spring.security.oauth2.client = {
        registration.pocketid = {
          client-name = "Pocket ID";
          provider = "pocketid";
          scope = "openid,email,profile,groups";
          authorization-grant-type = "authorization_code";
          redirect-uri = "{baseUrl}/{action}/oauth2/code/{registrationId}";
        };
        provider.pocketid = {
          issuer-uri = "https://auth.dimoracosta.it";
          user-name-attribute = "sub";
        };
      };
    };
  };

  systemd.tmpfiles.rules = ["d /var/lib/komga/data 0750 komga komga -"];

  # Read the Suwayomi downloads
  users.users.komga.extraGroups = ["suwayomi"];

  systemd.services.komga.serviceConfig = {
    EnvironmentFile = config.sops.templates.komgaEnv.path;
    # The library saved in Komga's database is /data, like in the container
    BindPaths = ["/var/lib/komga/data:/data"];
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.komga = {
      rule = "Host(`manga.dimoracosta.it`)";
      entryPoints = ["websecure"];
      service = "komga";
    };
    services.komga.loadBalancer.servers = [{url = "http://127.0.0.1:25600";}];
  };
}
