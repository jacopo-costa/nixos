# Pocket-ID: OIDC provider for every other app. Data: /var/lib/pocket-id
{config, ...}: {
  sops.secrets = {
    "pocket-id/encryptionKey" = {};
    "pocket-id/maxmindLicenseKey" = {};
  };

  services.pocket-id = {
    enable = true;
    settings = {
      APP_URL = "https://auth.dimoracosta.it";
      TRUST_PROXY = true;
      PORT = 1411;
    };
    credentials = {
      ENCRYPTION_KEY = config.sops.secrets."pocket-id/encryptionKey".path;
      MAXMIND_LICENSE_KEY = config.sops.secrets."pocket-id/maxmindLicenseKey".path;
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.pocket-id = {
      rule = "Host(`auth.dimoracosta.it`)";
      entryPoints = ["websecure"];
      service = "pocket-id";
    };
    services.pocket-id.loadBalancer.servers = [{url = "http://127.0.0.1:1411";}];
  };
}
