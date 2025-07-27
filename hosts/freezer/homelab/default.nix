{config, ...}: let
  hl = config.homelab;
  smtpHost = "smtp.gmail.com";
  smtpPort = 587;
  smtpUsername = "dimoracosta.system@gmail.com";
in {
  sops = {
    secrets.secrets.smtpPassword = {};

    secrets.cloudflareToken = {};

    secrets.vaultwardenAdminToken = {};

    secrets.authentikPgPass = {};
    secrets.authentikSecretKey = {};

    templates = {
      traefikEnv.content = ''
        CF_DNS_API_TOKEN=${config.sops.placeholder.cloudflareToken}
      '';
      vaultwardenEnv.content = ''
        DOMAIN=https://vault.${hl.baseDomain}
        SIGNUPS_ALLOWED=false
        ADMIN_TOKEN='${config.sops.placeholder.vaultwardenAdminToken}'
        ROCKET_ADDRESS=127.0.0.1
        ROCKET_PORT=8222
        SMTP_HOST=${smtpHost}
        SMTP_PORT=${smtpPort}
        SMTP_FROM=${smtpUsername}
        SMTP_FROM_NAME=CostaVault
        SMTP_USERNAME=${smtpUsername}
        SMTP_PASSWORD=${config.sops.placeholder.smtpPassword}
        SMTP_TIMEOUT=10
        EXTENDED_LOGGING=true
        LOG_LEVEL=warn
      '';
      authentikEnv.content = ''
        POSTGRES_PASSWORD=${config.sops.placeholder.authentikPgPass}
        POSTGRES_USER=authentik
        POSTGRES_DB=authentik
        AUTHENTIK_REDIS__HOST=redis
        AUTHENTIK_POSTGRESQL__HOST=postgresql
        AUTHENTIK_POSTGRESQL__USER=authentik
        AUTHENTIK_POSTGRESQL__NAME=authentik
        AUTHENTIK_POSTGRESQL__PASSWORD=${config.sops.placeholder.authentikPgPass}
        AUTHENTIK_SECRET_KEY=${config.sops.placeholder.authentikSecretKey}
        AUTHENTIK_ERROR_REPORTING__ENABLED=true
        AUTHENTIK_EMAIL__HOST=${smtpHost}
        AUTHENTIK_EMAIL__PORT=${smtpPort}
        AUTHENTIK_EMAIL__USERNAME=${smtpUsername}
        AUTHENTIK_EMAIL__PASSWORD=${config.sops.placeholder.smtpPassword}
        AUTHENTIK_EMAIL__USE_TLS=true
        AUTHENTIK_EMAIL__USE_SSL=false
        AUTHENTIK_EMAIL__TIMEOUT=10
        AUTHENTIK_EMAIL__FROM=${smtpUsername}
      '';
    };
  };

  homelab = {
    enable = true;
    timeZone = "Europe/Rome";
    services = {
      enable = true;
      containerizationType = "docker";

      traefik = {
        enable = true;
        traefikEnvPath = config.sops.templates.traefikEnv.path;
      };

      authentik = {
        enable = true;
        authentikEnvPath = config.sops.templates.authentikEnv.path;
      };
    };
  };
}
