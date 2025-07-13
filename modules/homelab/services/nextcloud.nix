{pkgs, ...}: {
  services = {
    # Change port of Nextcloud
    nginx.virtualHosts."localhost".listen = [
      {
        addr = "127.0.0.1";
        port = 8123;
      }
    ];

    nextcloud = {
      enable = true;
      hostName = "cloud.dimoracosta.it";
      autoUpdateApps.enable = true;
      https = true;

      home = "/tank/nextcloud";

      # Enable Redis
      configureRedis = true;
      caching = {
        redis = true;
      };

      # Max upload size
      maxUploadSize = "1G";

      settings = {
        redis = {
          host = "127.0.0.1";
          port = 31638;
          dbindex = 0;
          timeout = 1.5;
        };

        # Trust local traefik
        trusted_proxies = [
          "127.0.0.1"
        ];

        # Enable mail delivery
        mail_smtpmode = "sendmail";
        mail_sendmailmode = "pipe";

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

        default_phone_region = "IT";
      };

      config = {
        dbtype = "pgsql";
        dbuser = "nextcloud";
        dbname = "nextcloud";
        dbhost = "/run/postgresql";

        adminuser = "admin";
        adminpassFile = "${config.sops.secrets.nextcloudPass.path}";
      };
    };

    postgresql = {
      enable = true;
      ensureDatabases = ["nextcloud"];
      ensureUsers = [
        {
          name = "nextcloud";
          ensureDBOwnership = true;
        }
      ];
    };

    redis.servers.nextcloud = {
      enable = true;
      port = 31638;
      bind = "127.0.0.1";
    };
  };

  systemd = {
    services."nextcloud-setup" = {
      requires = ["postgresql.service"];
      after = ["postgresql.service"];
    };
  };
}
