{config, ...}: let
  homelab = config.homelab;
  smtpHost = "smtp.gmail.com";
  smtpPort = 587;
in {
  sops = {
    secrets."smtp/user" = {};

    secrets.cloudflareToken = {};

    secrets.vaultwardenAdminToken = {};

    # Pocket ID secrets
    secrets.maxmindLicenseKey = {};
    secrets.pocketIdEncKey = {};

    # Immich
    secrets."immich/db_username" = {};
    secrets."immich/db_password" = {};
    secrets."immich/db_name" = {};

    templates = {
      cloudflareEnv.content = ''
        CF_DNS_API_TOKEN=${config.sops.placeholder.cloudflareToken}
      '';
      vaultwardenEnv.content = ''
        DOMAIN=https://vault.${homelab.baseDomain}
        SIGNUPS_ALLOWED=false
        ADMIN_TOKEN='${config.sops.placeholder.vaultwardenAdminToken}'
        ROCKET_ADDRESS=127.0.0.1
        ROCKET_PORT=80
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
      pocketIdEnv.content = ''
        APP_URL=https://auth.${homelab.baseDomain}
        TRUST_PROXY=true
        MAXMIND_LICENSE_KEY=${config.sops.placeholder.maxmindLicenseKey}
        ENCRYPTION_KEY=${config.sops.placeholder.pocketIdEncKey}
      '';
      immichEnv.content = ''
        UPLOAD_LOCATION=/mnt/tank/immich
        DB_DATA_LOCATION=/srv/immich/postgres

        TZ=Europe/Rome

        IMMICH_VERSION=release

        DB_PASSWORD=${config.sops.placeholder."immich/db_password"}
        DB_USERNAME=${config.sops.placeholder."immich/db_username"}
        DB_DATABASE_NAME=${config.sops.placeholder."immich/db_name"}

        POSTGRES_PASSWORD=${config.sops.placeholder."immich/db_password"}
        POSTGRES_USER=${config.sops.placeholder."immich/db_username"}
        POSTGRES_DB=${config.sops.placeholder."immich/db_name"}
        POSTGRES_INITDB_ARGS=--data-checksums
      '';
    };
  };
  homelab = {
    enable = true;
    user = "ice";
    group = "ice";
    timeZone = "Europe/Rome";
    baseDomain = "dimoracosta.it";
    containers = {
      enable = true;

      # Crowdsec
      crowdsec.enable = true;

      # Traefik
      traefik = {
        enable = true;
        cloudflareEnvPath = config.sops.templates.cloudflareEnv.path;
      };

      # Pocket ID
      pocket-id = {
        enable = true;
        pocketIdEnvPath = config.sops.templates.pocketIdEnv.path;
      };

      # Vaultwarden
      vaultwarden = {
        enable = true;
        vaultwardenEnvPath = config.sops.templates.vaultwardenEnv.path;
      };

      # Immich
      immich = {
        enable = true;
        immichEnvPath = config.sops.templates.immichEnv.path;
      };
    };
  };

  virtualisation.libvirtd.allowedBridges = [
    "br0"
  ];
}
