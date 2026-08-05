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
        BORG_RUNNING_COMPOSES=$(for c in $(${dockerCli} ps -q); do ${dockerCli} inspect "$c" --format '{{ index .Config.Labels "com.docker.compose.project.config_files" }}'; done | grep -v '^$' | sort -u)
        if [ -n "$BORG_RUNNING_COMPOSES" ]; then
          for c in $BORG_RUNNING_COMPOSES; do
	    ${dockerCli} compose -f $c stop;
          done;
        fi
      '';

      postHook = ''
        if [ -n "$BORG_RUNNING_COMPOSES" ]; then
          for c in $BORG_RUNNING_COMPOSES; do
            ${dockerCli} compose -f $c start;
          done;
        fi
        ${pkgs.borgbackup}/bin/borg compact "${borgRepo}"
        ${emailOnFailure}
      '';
    };
  };
}
