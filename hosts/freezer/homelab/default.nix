{config, ...}: let
  hl = config.homelab;
  smtpHost = "smtp.gmail.com";
  smtpPort = 587;
in {
  sops = {
    secrets."smtp/user" = {};
    secrets."smtp/password" = {
      owner = "ice";
      group = hl.group;
      mode = "0440";
    };

    secrets.cloudflareToken = {};

    secrets.vaultwardenAdminToken = {};

    secrets.nextcloudAdminPass = {};

    secrets.paperlessAdminPass = {};

    secrets.authentikSecretKey = {};

    templates = {
      cloudflareEnv.content = ''
        CF_DNS_API_TOKEN=${config.sops.placeholder.cloudflareToken}
      '';
      vaultwardenEnv.content = ''
        DOMAIN=https://vault.${hl.baseDomain}
        SIGNUPS_ALLOWED=false
        ADMIN_TOKEN='${config.sops.placeholder.vaultwardenAdminToken}'
        ROCKET_ADDRESS=127.0.0.1
        ROCKET_PORT=8222
        SMTP_HOST=${smtpHost}
        SMTP_PORT=${toString smtpPort}
        SMTP_FROM=${config.sops.placeholder."smtp/user"}
        SMTP_FROM_NAME=CostaVault
        SMTP_USERNAME=${config.sops.placeholder."smtp/user"}
        SMTP_PASSWORD=${config.sops.placeholder."smtp/password"}
        SMTP_TIMEOUT=10
        EXTENDED_LOGGING=true
        LOG_LEVEL=warn
        IP_HEADER=X-Forwarded-For
      '';
      authentikEnv.content = ''
        AUTHENTIK_SECRET_KEY=${config.sops.placeholder.authentikSecretKey}
        AUTHENTIK_ERROR_REPORTING__ENABLED=true
        AUTHENTIK_EMAIL__HOST=${smtpHost}
        AUTHENTIK_EMAIL__PORT=${toString smtpPort}
        AUTHENTIK_EMAIL__USERNAME=${config.sops.placeholder."smtp/user"}
        AUTHENTIK_EMAIL__PASSWORD=${config.sops.placeholder."smtp/password"}
        AUTHENTIK_EMAIL__USE_TLS=true
        AUTHENTIK_EMAIL__FROM=Authentik <${config.sops.placeholder."smtp/user"}>
      '';
    };
  };

  homelab = {
    enable = true;
    timeZone = "Europe/Rome";
    services = {
      containerization = false;
      containerizationType = "docker";

      # Reverse proxy
      caddy = {
        enable = true;
        cloudflareEnvPath = config.sops.templates.cloudflareEnv.path;
      };

      # Passwords
      vaultwarden = {
        enable = true;
        vaultwardenEnvPath = config.sops.templates.vaultwardenEnv.path;
      };

      # ARR
      flaresolverr.enable = true;
      jellyseerr.enable = true;
      prowlarr.enable = true;
      radarr.enable = true;
      sonarr.enable = true;

      deluge.enable = true;

      jellyfin.enable = true;

      # OIDC Auth
      authentik = {
        enable = true;
        authentikEnvPath = config.sops.templates.authentikEnv.path;
      };

      # Photos
      immich.enable = true;

      # Cloud
      nextcloud = {
        enable = true;
        nextcloudAdminPassPath = config.sops.secrets.nextcloudAdminPass.path;
      };

      # Paperless
      paperless = {
        enable = false;
        paperlessAdminPassPath = config.sops.secrets.paperlessAdminPass.path;
      };
    };
  };
}
