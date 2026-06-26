{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.nextcloud;
  homelab = config.homelab;
  ncHome = config.services.nextcloud.home;
in {
  options.homelab.services.nextcloud = {
    enable = lib.mkEnableOption "Nextcloud cloud storage";
    url = lib.mkOption {
      type = lib.types.str;
      default = "cloud.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8083;
    };
    adminUser = lib.mkOption {
      type = lib.types.str;
      default = "admin";
    };
    nextcloudAdminPassPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to file containing the Nextcloud admin password";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/mnt/tank/nextcloud";
      description = "Directory for Nextcloud user data (bind-mounted into the Nextcloud home)";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts.${cfg.url} = {
      listen = [{ addr = "127.0.0.1"; port = cfg.port; }];
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = ["nextcloud"];
      ensureUsers = [
        {
          name = "nextcloud";
          ensureDBOwnership = true;
        }
      ];
    };

    services.nextcloud = {
      enable = true;
      hostName = cfg.url;
      datadir = cfg.dataDir;

      autoUpdateApps.enable = true;
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps) contacts calendar tasks notes bookmarks user_oidc;
      };

      configureRedis = true;
      maxUploadSize = "50G";

      notify_push = {
        enable = true;
        nextcloudUrl = "http://127.0.0.1:${toString cfg.port}";
      };

      config = {
        dbtype = "pgsql";
        dbuser = "nextcloud";
        dbhost = "/run/postgresql";
        dbname = "nextcloud";
        adminuser = cfg.adminUser;
        adminpassFile = cfg.nextcloudAdminPassPath;
      };

      settings = {
        trusted_proxies = ["127.0.0.1"];
        overwriteprotocol = "https";
        overwritehost = cfg.url;
        "overwrite.cli.url" = "https://${cfg.url}";

        default_phone_region = "IT";
        forwarded_for_headers = ["HTTP_X_FORWARDED_FOR"];

        # SMTP (non-secret — password goes in ${ncHome}/config/smtp.config.php via sops)
        mail_smtpmode = "smtp";
        mail_smtphost = config.email.smtpServer;
        mail_smtpport = config.email.smtpPort;
        mail_smtpname = config.email.smtpUsername;
        mail_smtpauth = true;
        mail_smtpauth_type = "LOGIN";
        mail_smtpsecure = "tls";
        mail_from_address = lib.head (lib.splitString "@" config.email.fromAddress);
        mail_domain = lib.last (lib.splitString "@" config.email.fromAddress);

        enabledPreviewProviders = [
          "OC\\Preview\\BMP"
          "OC\\Preview\\GIF"
          "OC\\Preview\\JPEG"
          "OC\\Preview\\Krita"
          "OC\\Preview\\MarkDown"
          "OC\\Preview\\MP3"
          "OC\\Preview\\OpenDocument"
          "OC\\Preview\\PNG"
          "OC\\Preview\\TXT"
          "OC\\Preview\\XBitmap"
          "OC\\Preview\\HEIC"
        ];

        "opcache.interned_strings_buffer" = 64;
        log_type = "file";
        maintenance_window_start = 1;
        "integrity.check.disabled" = false;
      };
    };

    systemd.services."nextcloud-setup" = {
      requires = ["postgresql.target"];
      after = ["postgresql.target" "newt.service"];
      wants = ["newt.service"];
    };
  };
}
