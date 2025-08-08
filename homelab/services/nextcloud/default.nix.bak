{
  config,
  lib,
  ...
}: let
  service = "nextcloud";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in {
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
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
    };
  };
  config = lib.mkIf cfg.enable {
    services.nginx = {
      virtualHosts."${config.services.nextcloud.hostName}" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = cfg.port;
          }
        ];
      };
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

    systemd.services."nextcloud-setup" = {
      requires = ["postgresql.service"];
      after = ["postgresql.service"];
    };

    services.${service} = {
      enable = true;
      hostName = "nextcloud";

      configureRedis = true;
      caching = {
        redis = true;
      };

      maxUploadSize = "50G";

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
        overwrite.cli.url = "https://${cfg.url}";

        default_phone_region = "IT";

        forwarded_for_headers = [
          "HTTP_X_FORWARDED_FOR"
        ];
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

        opcache.interned_strings_buffer = 64;

        log_type = "file";

        maintenance_window_start = 1;

        integrity.check.disabled = false;
      };
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}

        header {
          Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        }
      '';
    };
  };
}
