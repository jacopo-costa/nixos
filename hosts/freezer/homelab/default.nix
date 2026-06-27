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

    secrets."newt/id" = {};
    secrets."newt/secret" = {};

    secrets."pocket-id/maxmindLicenseKey" = {};
    secrets."pocket-id/encryptionKey" = {};

    secrets.vaultwardenAdminToken = {};

    secrets."gluetun/privateKey" = {};
    secrets."gluetun/addresses" = {};

    secrets."nextcloud/mariadbRootPass" = {};
    secrets."nextcloud/mariadbPass" = {};
    secrets."nextcloud/adminPass" = {};

    # secrets."frigate/mqttPassword" = {};
    # secrets."frigate/rtspPassword" = {};

    templates = {
      newtEnv.content = ''
        PANGOLIN_ENDPOINT=https://pangolin.${hl.baseDomain}
        NEWT_ID=${config.sops.placeholder."newt/id"}
        NEWT_SECRET=${config.sops.placeholder."newt/secret"}
      '';

      pocketIdEnv.content = ''
        APP_URL=https://auth.${hl.baseDomain}
        TRUST_PROXY=true
        MAXMIND_LICENSE_KEY=${config.sops.placeholder."pocket-id/maxmindLicenseKey"}
        ENCRYPTION_KEY=${config.sops.placeholder."pocket-id/encryptionKey"}
      '';

      gluetunEnv.content = ''
        WIREGUARD_PRIVATE_KEY=${config.sops.placeholder."gluetun/privateKey"}
        WIREGUARD_ADDRESSES=${config.sops.placeholder."gluetun/addresses"}
      '';

      nextcloudEnv.content = ''
        # MariaDB
        MYSQL_ROOT_PASSWORD=${config.sops.placeholder."nextcloud/mariadbRootPass"}
        MYSQL_PASSWORD=${config.sops.placeholder."nextcloud/mariadbPass"}
        MYSQL_DATABASE=nextcloud
        MYSQL_USER=nextcloud

        MYSQL_HOST=nextcloud_mariadb
        REDIS_HOST=nextcloud_redis

        # Admin
        NEXTCLOUD_ADMIN_USER=admin
        NEXTCLOUD_ADMIN_PASSWORD='${config.sops.placeholder."nextcloud/adminPass"}'

        NEXTCLOUD_TRUSTED_DOMAINS=cloud.dimoracosta.it
        APACHE_DISABLE_REWRITE_IP=1
        TRUSTED_PROXIES=172.17.0.1

        # SMTP
        SMTP_HOST=${smtpHost}
        SMTP_PORT=${toString smtpPort}
        SMTP_NAME=${config.sops.placeholder."smtp/user"}
        SMTP_PASSWORD=${config.sops.placeholder."smtp/password"}
        MAIL_FROM_ADDRESS=dimoracosta.system
        MAIL_DOMAIN=gmail.com
      '';

      vaultwardenEnv.content = ''
        DOMAIN=https://vault.${hl.baseDomain}
        SIGNUPS_ALLOWED=false
        ADMIN_TOKEN='${config.sops.placeholder.vaultwardenAdminToken}'
        ROCKET_ADDRESS=127.0.0.1
        ROCKET_PORT=${toString hl.services.vaultwarden.port}
        SMTP_HOST=${smtpHost}
        SMTP_PORT=${toString smtpPort}
        SMTP_FROM=${config.sops.placeholder."smtp/user"}
        SMTP_FROM_NAME=CostaVault
        SMTP_USERNAME=${config.sops.placeholder."smtp/user"}
        SMTP_PASSWORD=${config.sops.placeholder."smtp/password"}
        SMTP_TIMEOUT=10
        SMTP_SECURITY=starttls
        EXTENDED_LOGGING=true
        LOG_LEVEL=warn
        IP_HEADER=X-Forwarded-For
      '';
    };
  };

  homelab = {
    enable = true;
    user = "ice";
    group = "ice";
    timeZone = "Europe/Rome";
    baseDomain = "dimoracosta.it";
    localDomain = "freezer.lan";

    services = {
      enable = true;

      # Newt
      newt = {
        enable = true;
        newtEnvPath = config.sops.templates.newtEnv.path;
      };

      # Local LAN reverse proxy
      nginx-local.enable = true;

      # OIDC Auth
      pocket-id = {
        enable = true;
        pocketIdEnvPath = config.sops.templates.pocketIdEnv.path;
      };

      # Passwords
      vaultwarden = {
        enable = true;
        vaultwardenEnvPath = config.sops.templates.vaultwardenEnv.path;
      };

      # ARR
      flaresolverr.enable = true;
      seerr.enable = true;
      prowlarr.enable = true;
      radarr.enable = true;
      sonarr.enable = true;
      lidarr.enable = false;
      bazarr.enable = true;

      # Downloaders
      sabnzbd.enable = true;
      qbittorrent = {
        enable = true;
        gluetunEnvPath = config.sops.templates.gluetunEnv.path;
      };

      jellyfin.enable = true;

      # Surveillance
      frigate = {
        enable = false;
        vaapiDriver = "iHD";
        environmentFilePath = config.sops.templates.frigateEnv.path;
        openRtsp = true;
        openWebRtc = true;
        settings = {
          tls.enabled = false;

          mqtt = {
            enabled = true;
            host = "192.168.30.3";
            port = 1883;
            user = "mqtt-user";
            # resolved at runtime via FRIGATE_MQTT_PASSWORD env var
            password = "{FRIGATE_MQTT_PASSWORD}";
          };

          detectors.ov = {
            type = "openvino";
            device = "AUTO";
          };

          # NOTE: these paths are Docker-specific (/openvino-model/...).
          # On NixOS, verify the correct path with:
          #   find $(nix-build '<nixpkgs>' -A frigate --no-out-link) -name '*.xml' 2>/dev/null
          model = {
            width = 300;
            height = 300;
            input_tensor = "nhwc";
            input_pixel_format = "bgr";
            path = "/openvino-model/ssdlite_mobilenet_v2.xml";
            labelmap_path = "/openvino-model/coco_91cl_bkgr.txt";
          };

          detect = {
            enabled = true;
            fps = 15;
          };

          motion = {
            enabled = true;
            threshold = 30;
            contour_area = 50;
            improve_contrast = false;
          };

          record = {
            enabled = true;
            continuous.days = 0;
            motion.days = 3;
          };

          snapshots = {
            enabled = true;
            retain.default = 30;
          };

          audio = {
            enabled = true;
            max_not_heard = 30;
            min_volume = 500;
          };

          cameras = {
            portico = {
              enabled = true;
              type = "generic";
              detect = {
                width = 640;
                height = 360;
              };
              ffmpeg.inputs = [
                {
                  path = "rtsp://admin:{FRIGATE_RTSP_PASSWORD}@192.168.20.2:8554/profile1";
                  roles = ["detect" "audio"];
                }
                {
                  path = "rtsp://admin:{FRIGATE_RTSP_PASSWORD}@192.168.20.2:8554/profile0";
                  roles = ["record"];
                }
              ];
            };
            mutine = {
              enabled = true;
              type = "generic";
              detect = {
                width = 640;
                height = 360;
              };
              ffmpeg.inputs = [
                {
                  path = "rtsp://admin:{FRIGATE_RTSP_PASSWORD}@192.168.20.3:8554/profile1";
                  roles = ["detect" "audio"];
                }
                {
                  path = "rtsp://admin:{FRIGATE_RTSP_PASSWORD}@192.168.20.3:8554/profile0";
                  roles = ["record"];
                }
              ];
            };
            galline = {
              enabled = true;
              type = "generic";
              detect = {
                width = 640;
                height = 360;
              };
              ffmpeg.inputs = [
                {
                  path = "rtsp://admin:{FRIGATE_RTSP_PASSWORD}@192.168.20.4:8554/profile1";
                  roles = ["detect" "audio"];
                }
                {
                  path = "rtsp://admin:{FRIGATE_RTSP_PASSWORD}@192.168.20.4:8554/profile0";
                  roles = ["record"];
                }
              ];
            };
            giardino = {
              enabled = true;
              type = "generic";
              detect = {
                width = 640;
                height = 360;
              };
              ffmpeg.inputs = [
                {
                  path = "rtsp://admin:{FRIGATE_RTSP_PASSWORD}@192.168.20.5:8554/profile1";
                  roles = ["detect" "audio"];
                }
                {
                  path = "rtsp://admin:{FRIGATE_RTSP_PASSWORD}@192.168.20.5:8554/profile0";
                  roles = ["record"];
                }
              ];
            };
          };
        };
      };

      # Photos
      immich.enable = false;

      # Cloud
      nextcloud = {
        enable = false;
        nextcloudEnvPath = config.sops.templates.nextcloudEnv.path;
      };
    };
  };

  virtualisation.libvirtd.allowedBridges = [
    "br0"
  ];
}
