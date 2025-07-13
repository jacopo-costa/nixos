{config, ...}: {
  sops = {
    # SMTP Credentials
    secrets."smtpPassword" = {};
    secrets."smtpUser" = {};

    # Vaultwarden
    secrets."adminToken" = {};
    templates.vaultwardenEnv = {
      content = ''
        DOMAIN = https://vault.dimoracosta.it
        SIGNUPS_ALLOWED = false

        ADMIN_TOKEN = ${config.sops.placeholder.adminToken}

        ROCKET_ADDRESS = 127.0.0.1
        ROCKET_PORT = 8222

        ROCKET_LOG = critical

        SMTP_HOST = smtp.gmail.com
        SMTP_SECURITY= starttls
        SMTP_PORT = 587

        SMTP_USERNAME = ${config.sops.placeholder.smtpUser}
        SMTP_PASSWORD = ${config.sops.placeholder.smtpPassword}

        SMTP_FROM = ${config.sops.placeholder.smtpUser}
        SMTP_FROM_NAME = "Vaultwarden DimoraCosta"
      '';
      path = "/etc/vaultwarden/vaultwarden.env";
    };
  };

  services.vaultwarden = {
    enable = true;
    environmentFile = config.sops.templates.vaultwardenEnv.path;
  };
}
