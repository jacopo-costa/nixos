{
  config,
  lib,
  pkgs,
  ...
}: let
  borgRepo = "/mnt/tank/backup/borg/freezer";

  # Stopped during the backup so their databases are copied in a consistent state.
  # Only the ones that exist are used, so commenting out an app in ../services is enough.
  # If the backup is interrupted by a crash, systemd starts them again at boot.
  apps = lib.filter (unit: config.systemd.services ? ${unit}) [
    "crowdsec"
    "pocket-id"
    "vaultwarden"
    "sonarr"
    "radarr"
    "prowlarr"
    "bazarr"
    "sabnzbd"
    "seerr"
    "jellyfin"
    "komga"
    "suwayomi-server"
    "immich-server"
    "immich-machine-learning"
    "phpfpm-nextcloud"
    "frigate"
    "podman-qbittorrent"
    "podman-gluetun"
    "podman-sparkyfitness-frontend"
    "podman-sparkyfitness-server"
    "podman-sparkyfitness-db"
    "podman-trek"
    "podman-calibre-web-automated"
    # Databases last (systemd stops the apps that need them first anyway)
    "postgresql"
    "mysql"
  ];
  units = lib.concatMapStringsSep " " (unit: "${unit}.service") apps;
  systemctl = "${config.systemd.package}/bin/systemctl";

  # body is double-quoted so shell variables in it expand
  sendMail = subject: body:
    if config.email.enable
    then ''
      printf '%s\n' "To: ${config.email.toAddress}" "From: ${config.email.fromAddress}" "Subject: [freezer] ${subject}" "" "${body}" | \
        ${pkgs.msmtp}/bin/msmtp ${config.email.toAddress}
    ''
    else ":";
in {
  environment.systemPackages = [pkgs.borgbackup];

  services.borgbackup.jobs = {
    freezer-local = {
      paths = [
        # App state and databases (pocket-id, vaultwarden, arr, jellyfin, postgres, mysql, containers...)
        "/var/lib"
        "/opt/suwayomi"
        "/mnt/tank/nextcloud"
        "/mnt/tank/immich"
      ];
      exclude = [
        # Container images: downloaded again
        "/var/lib/containers"
        # Old docker data, until it's deleted after the migration
        "/var/lib/docker"
        # VM disks
        "/var/lib/libvirt"
      ];

      repo = borgRepo;
      compression = "auto,zstd";
      encryption.mode = "none";

      startAt = "Mon *-*-* 03:00:00";

      prune.keep = {
        weekly = 2;
        monthly = 2;
      };

      preHook = ''
        ${systemctl} stop ${units}
      '';

      # Runs even when the backup fails
      postHook = ''
        startFailed=0
        ${systemctl} start ${units} || startFailed=1
        if [ "$exitStatus" != "0" ] || [ "$startFailed" != "0" ]; then
          ${sendMail "Borg backup failed" "Backup exit code: $exitStatus. App restart failed: $startFailed (check: systemctl --failed)."}
        fi
      '';
    };
  };
}
