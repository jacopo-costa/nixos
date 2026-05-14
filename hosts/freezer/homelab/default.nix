{config, ...}: let
  hl = config.homelab;
  smtpHost = "smtp.gmail.com";
  smtpPort = 587;
in {
  sops = {
    secrets."smtp/user" = {};
    secrets."smtp/password" = {
      group = hl.group;
      mode = "0440";
    };

    # Caddy + Crowdsec
    secrets.cloudflareToken = {};
    secrets.crowdsecBouncerKey = {};

    # Pocket-ID
    secrets."pocket-id/maxmindLicenseKey" = {};
    secrets."pocket-id/encryptionKey" = {};

    secrets.vaultwardenAdminToken = {};

    templates = {
      cloudflareEnv.content = ''
        CF_DNS_API_TOKEN=${config.sops.placeholder.cloudflareToken}
        CROWDSEC_BOUNCER_KEY=${config.sops.placeholder.crowdsecBouncerKey}
      '';

      pocketIdEnv.content = ''
        TRUST_PROXY=true
        MAXMIND_LICENSE_KEY=${config.sops.placeholder."pocket-id/maxmindLicenseKey"}
        ENCRYPTION_KEY=${config.sops.placeholder."pocket-id/encryptionKey"}
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
        IP_HEADER=X-Real-IP
      '';
    };
  };

  homelab = {
    enable = true;
    user = "ice";
    group = "ice";
    timeZone = "Europe/Rome";
    baseDomain = "dimoracosta.it";

    services = {
      enable = true;

      # Reverse proxy
      caddy = {
        enable = false;
        cloudflareEnvPath = config.sops.templates.cloudflareEnv.path;
      };

      # OIDC Auth
      pocket-id = {
        enable = false;
        pocketIdEnvPath = config.sops.templates.pocketIdEnv.path;
      };

      # Passwords
      vaultwarden = {
        enable = false;
        vaultwardenEnvPath = config.sops.templates.vaultwardenEnv.path;
      };

      # ARR
      # flaresolverr.enable = true;
      # jellyseerr.enable = true;
      # prowlarr.enable = true;
      # radarr.enable = true;
      # sonarr.enable = true;

      # deluge.enable = true;

      # jellyfin.enable = true;

      # # OIDC Auth

      # # Photos
      # immich.enable = true;

      # # Cloud
      # nextcloud.enable = true;
    };
  };

  virtualisation.libvirtd.allowedBridges = [
    "br0"
  ];
}
