{config, ...}: let
  hl = config.homelab;
  smtpHost = "smtp.gmail.com";
  smtpPort = 587;
  smtpUsername = "dimoracosta.system@gmail.com";
in {
  sops = {
    secrets."smtp.password" = {};

    secrets.cloudflareToken = {};

    secrets.vaultwardenAdminToken = {};

    secrets."openWebUi.clientId" = {};
    secrets."openWebUi.clientSecret" = {};

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
        SMTP_PASSWORD=${config.sops.placeholder."smtp.password"}
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
        SMTP_PASSWORD=${config.sops.placeholder."smtp.password"}
      '';
      openWebUiEnv.content = ''
        ENABLE_OAUTH_SIGNUP=true
        OAUTH_CLIENT_ID=${config.sops.placeholder."openWebUi.clientId"}
        OAUTH_CLIENT_SECRET=${config.sops.placeholder."openWebUi.clientSecret"}
        OAUTH_PROVIDER_NAME="Pocket ID"
        OPENID_PROVIDER_URL=https://login.dimoracosta.it/.well-known/openid-configuration
        OAUTH_MERGE_ACCOUNTS_BY_EMAIL=true

        # For group management, you can use the following variables:
        ENABLE_OAUTH_ROLE_MANAGEMENT=true
        ENABLE_OAUTH_GROUP_MANAGEMENT=true
        ENABLE_OAUTH_GROUP_CREATION=true
        # Make sure those match the ones you set up before in Pocket-ID
        OAUTH_ALLOWED_ROLES="users, admins"
        OAUTH_ADMIN_ROLES=admins
        OAUTH_ROLES_CLAIM=groups
        OAUTH_SCOPES="openid email profile groups"

        # Optional but useful variables:

        # So users are immediately added instead of being "pending"
        DEFAULT_USER_ROLE=user
        # Make Pocket-ID the only auth method
        # comment out if you need access via password
        ENABLE_LOGIN_FORM=false
        # Make Pocket-ID the source of truth for the profile pictures
        OAUTH_UPDATE_PICTURE_ON_LOGIN=true
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

      # LLM
      ollama.enable = true;
      open-webui = {
        enable = true;
        openWebUiEnvPath = config.sops.templates.openWebUiEnv.path;
      };
    };
  };
}
