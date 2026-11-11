# Vaultwarden: password manager. Data: /var/lib/vaultwarden
{config, ...}: {
  sops = {
    secrets."vaultwarden/adminToken" = {};

    templates.vaultwardenEnv.content = ''
      ADMIN_TOKEN=${config.sops.placeholder."vaultwarden/adminToken"}
      SMTP_PASSWORD=${config.sops.placeholder."smtp/password"}
    '';
  };

  services.vaultwarden = {
    enable = true;
    environmentFile = config.sops.templates.vaultwardenEnv.path;
    config = {
      DOMAIN = "https://vault.dimoracosta.it";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      SMTP_HOST = config.email.smtpServer;
      SMTP_PORT = config.email.smtpPort;
      SMTP_SECURITY = "starttls";
      SMTP_USERNAME = config.email.smtpUsername;
      SMTP_FROM = config.email.fromAddress;
      SMTP_FROM_NAME = "CostaVault";
      SMTP_TIMEOUT = 10;
      EXTENDED_LOGGING = true;
      LOG_LEVEL = "warn";
      IP_HEADER = "X-Forwarded-For";
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.vaultwarden = {
      rule = "Host(`vault.dimoracosta.it`)";
      entryPoints = ["websecure"];
      service = "vaultwarden";
    };
    # /admin behind Pocket-ID, admins group only (longer rule wins over the one above)
    routers.vaultwarden-admin = {
      rule = "Host(`vault.dimoracosta.it`) && PathPrefix(`/admin`)";
      entryPoints = ["websecure"];
      middlewares = ["oidc-auth-admins@file"];
      service = "vaultwarden";
    };
    services.vaultwarden.loadBalancer.servers = [{url = "http://127.0.0.1:8222";}];
  };
}
