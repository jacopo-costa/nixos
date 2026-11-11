# Nextcloud: nginx + php-fpm (vhost on 127.0.0.1:8081, see ../nginx) and a local MariaDB.
# Config: /var/lib/nextcloud/config (config.php copied from docker, plus the module's override.config.php)
# Files: /mnt/tank/nextcloud, unchanged from docker. Apps from the app store: /var/lib/nextcloud/store-apps
{
  config,
  pkgs,
  ...
}: {
  services.nextcloud = {
    enable = true;
    # Same version as the docker image. Major upgrades: one step at a time (34 -> 35 -> ...)
    package = pkgs.nextcloud34;
    hostName = "cloud.dimoracosta.it";
    # Traefik terminates TLS: generate https links
    https = true;

    database.createLocally = true;
    configureRedis = true;

    config = {
      dbtype = "mysql";
      # Already installed (config.php copied from docker): no admin user to create
      adminuser = null;
      adminpassFile = null;
    };

    settings = {
      datadirectory = "/mnt/tank/nextcloud";
      trusted_proxies = ["127.0.0.1"];

      # Mail (the docker image built this from SMTP_* env vars)
      mail_smtpmode = "smtp";
      mail_smtphost = config.email.smtpServer;
      mail_smtpport = config.email.smtpPort;
      mail_smtpauth = true;
      mail_smtpname = config.email.smtpUsername;
      mail_from_address = "dimoracosta.system";
      mail_domain = "gmail.com";
    };

    secrets.mail_smtppassword = config.sops.secrets."smtp/password".path;
  };

  # Same major as the docker mariadb:11.8 the dump comes from
  services.mysql.package = pkgs.mariadb_118;

  # Files live on the pool: never start without it
  systemd.services = {
    nextcloud-setup = {
      requires = ["zfs-import-tank.service"];
      after = ["zfs-import-tank.service" "zfs-mount.service"];
    };
    phpfpm-nextcloud = {
      requires = ["zfs-import-tank.service"];
      after = ["zfs-import-tank.service" "zfs-mount.service"];
    };
  };

  # The `nginx` backend is defined in ../nginx
  services.traefik.dynamicConfigOptions.http.routers.nextcloud = {
    rule = "Host(`cloud.dimoracosta.it`)";
    entryPoints = ["websecure"];
    service = "nginx";
  };
}
