{
  config,
  lib,
  pkgs,
  ...
}: let
  borgRepo = "/mnt/tank/backup/borg/freezer";
  dockerCli = "${pkgs.docker}/bin/docker";
  emailOnFailure = lib.optionalString config.email.enable ''
    if [ "$exitStatus" != "0" ]; then
      printf 'To: ${config.email.toAddress}\nFrom: ${config.email.fromAddress}\nSubject: [freezer] Borg backup failed\n\nBackup job exited with code %s.\n' "$exitStatus" | \
        ${pkgs.msmtp}/bin/msmtp ${config.email.toAddress}
    fi
  '';
in {
  environment.systemPackages = [pkgs.borgbackup];

  services.borgbackup.jobs = {
    freezer-local = {
      paths = [
        "/srv/stacks"
	"/opt/suwayomi"
        "/var/lib/docker/volumes"
        "/mnt/tank/nextcloud"
        "/mnt/tank/immich"
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
        BORG_RUNNING_CONTAINERS=$(${dockerCli} ps -q)
        if [ -n "$BORG_RUNNING_CONTAINERS" ]; then
          ${dockerCli} stop $BORG_RUNNING_CONTAINERS
        fi
      '';

      postHook = ''
        if [ -n "$BORG_RUNNING_CONTAINERS" ]; then
          ${dockerCli} start $BORG_RUNNING_CONTAINERS
        fi
        ${pkgs.borgbackup}/bin/borg compact "${borgRepo}"
        ${emailOnFailure}
      '';
    };
  };
}
