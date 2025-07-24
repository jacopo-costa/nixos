{config, ...}: let
  hl = config.homelab;
in {
  # Cloudflare environment file
  sops = {
    secrets.nextcloudPass = {};
    secrets.smtpPassword = {};
    secrets.cloudflareToken = {};
    secrets.vaultwardenAdminToken = {};
    secrets.authentikKey = {};

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
        EXTENDED_LOGGING=true
        LOG_LEVEL=warn
        IP_HEADER=X-Real-IP
      '';
      authentikEnv.content = ''
        AUTHENTIK_SECRET_KEY=${config.sops.placeholder.authentikKey}
        AUTHENTIK_EMAIL__PASSWORD=${config.sops.placeholder.smtpPassword}
      '';
    };
  };

  homelab = {
    enable = true;
    baseDomain = "dimoracosta.it";
    timeZone = "Europe/Rome";
    services = {
      enable = true;
      cloudflareEnvPath = "${config.sops.templates.cloudflareEnv.path}";

      # ARR stack
      flaresolverr.enable = true;
      jellyseerr.enable = true;
      prowlarr.enable = true;
      radarr.enable = true;
      sonarr.enable = true;

      # Deluge
      deluge.enable = true;

      # Jellyfin
      jellyfin.enable = true;

      # Authentik
      authentik = {
        enable = true;
        environmentFile = config.sops.templates.authentikEnv.path;
        emailUsername = "dimoracosta.system@gmail.com";
      };

      # Nextcloud
      nextcloud = {
        enable = true;
        adminuser = "admin";
        adminpassFile = config.sops.secrets.nextcloudPass.path;
      };

      # Vaultwarden
      vaultwarden = {
        enable = true;
        vaultwardenEnvPath = config.sops.templates.vaultwardenEnv.path;
        url = "vault.${hl.baseDomain}";
      };
    };
  };
}
