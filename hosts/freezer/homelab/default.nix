{config, ...}: let
  hl = config.homelab;
  smtpHost = "smtp.gmail.com";
  smtpPort = 587;
  smtpUsername = "dimoracosta.system@gmail.com";
in {
  sops = {
    secrets."smtp/password" = {};

    secrets.cloudflareToken = {};

    secrets.vaultwardenAdminToken = {};

    secrets.paperlessAdminPass = {};

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
        SMTP_FROM=${smtpUsername}
        SMTP_FROM_NAME=CostaVault
        SMTP_USERNAME=${smtpUsername}
        SMTP_PASSWORD=${config.sops.placeholder."smtp/password"}
        SMTP_TIMEOUT=10
        EXTENDED_LOGGING=true
        LOG_LEVEL=warn
      '';
      pocketIdEnv.content = ''
        APP_URL=https://login.${hl.baseDomain}
        TRUST_PROXY=true
        PUID=994
        PGID=993
        SMTP_HOST=${smtpHost}
        SMTP_PORT=${toString smtpPort}
        SMTP_FROM=${smtpUsername}
        SMTP_USER=${smtpUsername}
        SMTP_PASSWORD=${config.sops.placeholder."smtp/password"}
      '';
    };
  };

  homelab = {
    enable = true;
    timeZone = "Europe/Rome";
    services = {
      enable = true;
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
      pocket-id = {
        enable = true;
        pocketIdEnvPath = config.sops.templates.pocketIdEnv.path;
      };

      # Photos
      immich.enable = true;

      # Cloud
      nextcloud.enable = true;

      # Paperless
      paperless = {
        enable = true;
        passwordFile = config.sops.secrets.paperlessAdminPass.path;
      };
    };
  };
}
