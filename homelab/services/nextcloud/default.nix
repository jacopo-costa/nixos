{config, ...}: {
  sops.secrets.nextcloudPass = {};

  services = {
    nextcloud = {
      enable = true;
      hostName = "cloud.dimoracosta.it";
      autoUpdateApps.enable = true;

      home = "/tank/nextcloud";

      # Enable Redis
      configureRedis = true;

      # DB
      database.createLocally = true;
      config = {
        dbtype = "pgsql";

        adminuser = "admin";
        adminpassFile = "${config.sops.secrets.nextcloudPass.path}";
      };

      # Max upload size
      maxUploadSize = "1G";

      settings = {
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
    };
  };

  services.nginx.virtualHosts."${config.services.nextcloud.hostName}".listen = [
    {
      addr = "127.0.0.1";
      port = 8123;
    }
  ];
}
