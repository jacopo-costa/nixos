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

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        AllowUsers = ["ice"];
      };
    };

    vaultwarden = {
      enable = true;
      environmentFile = config.sops.templates.vaultwardenEnv.path;
    };

    # ARR Stack
    jellyfin = {
      enable = true;
      group = "arr";
      # Ports 8096, 8920, 7359
      openFirewall = true;
    };

    jellyseerr = {
      enable = true;
      # Port 5055
      openFirewall = true;
    };

    deluge = {
      enable = true;
      web = {
        enable = true;
        # Port 8112
        openFirewall = true;
      };
      group = "arr";
    };

    prowlarr = {
      enable = true;
      # Port 9696
      openFirewall = true;
    };

    flaresolverr = {
      enable = true;
      # Port 8191
      openFirewall = true;
    };

    radarr = {
      enable = true;
      # Port 7878
      openFirewall = true;
      group = "arr";
    };

    sonarr = {
      enable = true;
      # Port 8989
      openFirewall = true;
      group = "arr";
    };
  };
}
