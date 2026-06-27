{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homelab.services.nextcloud;
in {
  options.homelab.services.nextcloud = {
    enable = lib.mkEnableOption "Nextcloud cloud storage";
    nextcloudEnvPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to file containing the Nextcloud environment variables";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/mnt/tank/nextcloud";
      description = "Directory for Nextcloud user data (bind-mounted into the Nextcloud home)";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8083;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.create-nextcloud-network = {
      description = "Create nextcloud Docker network";
      after = ["docker.service"];
      requires = ["docker.service"];
      before = [
        "docker-nextcloud-mariadb.service"
        "docker-nextcloud-redis.service"
      ];
      wantedBy = [
        "docker-nextcloud-mariadb.service"
        "docker-nextcloud-redis.service"
      ];
      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.docker}/bin/docker network inspect nextcloud > /dev/null 2>&1 || ${pkgs.docker}/bin/docker network create nextcloud
      '';
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/nextcloud      0750 root root -"
      "d /var/lib/nextcloud/db   0750 root root -"
      "d /var/lib/nextcloud/data 0750 root root -"
    ];

    virtualisation.oci-containers.containers = {
      nextcloud_mariadb = {
        image = "mariadb:lts";
        serviceName = "docker-nextcloud-mariadb";
        cmd = ["--transaction-isolation=READ-COMMITTED"];
        networks = ["nextcloud"];
        volumes = [
          "/var/lib/nextcloud/db:/var/lib/mysql"
        ];
        environmentFiles = [cfg.nextcloudEnvPath];
      };

      nextcloud_redis = {
        image = "redis:alpine";
        serviceName = "docker-nextcloud-redis";
        networks = ["nextcloud"];
      };

      nextcloud_cron = {
        image = "nextcloud:apache";
        serviceName = "docker-nextcloud-cron";
        entrypoint = "/cron.sh";
        networks = ["nextcloud"];
        volumes = [
          "/var/lib/nextcloud/data:/var/www/html"
          "${cfg.dataDir}:/var/www/html/data"
        ];
        dependsOn = [
          "nextcloud_mariadb"
          "nextcloud_redis"
        ];
      };

      nextcloud = {
        image = "nextcloud";
        serviceName = "docker-nextcloud";
        networks = ["nextcloud"];
        volumes = [
          "/var/lib/nextcloud/data:/var/www/html"
          "${cfg.dataDir}:/var/www/html/data"
        ];
        ports = ["127.0.0.1:${toString cfg.port}:80"];
        environmentFiles = [cfg.nextcloudEnvPath];
        dependsOn = [
          "nextcloud_mariadb"
          "nextcloud_redis"
        ];
      };
    };
  };
}
