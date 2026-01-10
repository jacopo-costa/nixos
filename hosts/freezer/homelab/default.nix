{config, ...}: let
  hl = config.homelab;
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
      pocketIdEnv.content = ''
        APP_URL=https://auth.${hl.baseDomain}
        TRUST_PROXY=true
        MAXMIND_LICENSE_KEY=${config.sops.placeholder.maxmindLicenseKey}
        ENCRYPTION_KEY=${config.sops.placeholder.pocketIdEncKey}
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
      crowdsec.enable = false;

      # Traefik
      traefik = {
        enable = false;
        cloudflareEnvPath = config.sops.templates.cloudflareEnv.path;
      };

      # Pocket ID
      pocket-id = {
        enable = false;
        pocketIdEnvPath = config.sops.templates.pocketIdEnv.path;
      };

      # Vaultwarden
      vaultwarden = {
        enable = false;
        vaultwardenEnvPath = config.sops.templates.vaultwardenEnv.path;
      };
    };
  };

  virtualisation.libvirtd.allowedBridges = [
    "br0"
  ];
}
