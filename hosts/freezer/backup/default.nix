{
  config,
  lib,
  pkgs,
  ...
}: let
  borgRepo = "/mnt/tank/backup/borg/freezer";
  dockerCli = "${config.virtualisation.docker.package}/bin/docker";
  # Compose files stopped by the backup; survives a crash so boot can restart them
  stateDir = "/var/lib/borg-compose";
  stoppedList = "${stateDir}/stopped";

  # Restart every stopped project, never abort halfway; sets startFailed=1 on any failure
  startStopped = ''
    set +e
    startFailed=0
    if [ -s ${stoppedList} ]; then
      while read -r c; do
        ${dockerCli} compose -f "$c" start < /dev/null || startFailed=1
      done < ${stoppedList}
    fi
    [ "$startFailed" = 0 ] && rm -f ${stoppedList}
  '';

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

  systemd.tmpfiles.rules = ["d ${stateDir} 0700 root root -"];

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
      readWritePaths = [stateDir];

      startAt = "Mon *-*-* 03:00:00";

      prune.keep = {
        weekly = 2;
        monthly = 2;
      };

      preHook = ''
        for c in $(${dockerCli} ps -q); do
          ${dockerCli} inspect "$c" --format '{{ index .Config.Labels "com.docker.compose.project.config_files" }}'
        done | grep -v '^$' | sort -u >> ${stoppedList}
        sort -u -o ${stoppedList} ${stoppedList}
        while read -r c; do
          ${dockerCli} compose -f "$c" stop < /dev/null
        done < ${stoppedList}
      '';

      postHook = ''
        ${startStopped}
        if [ "$exitStatus" != "0" ] || [ "$startFailed" != "0" ]; then
          ${sendMail "Borg backup failed" "Backup exit code: $exitStatus. Stack restart failed: $startFailed (still pending in ${stoppedList})."}
        fi
      '';
    };
  };

  # unless-stopped containers stay down after a crash/reboot mid-backup: restart them at boot
  systemd.services.borg-compose-restart = {
    description = "Restart compose stacks left stopped by an interrupted borg backup";
    after = ["docker.service"];
    requires = ["docker.service"];
    wantedBy = ["multi-user.target"];
    unitConfig.ConditionPathExists = stoppedList;
    serviceConfig.Type = "oneshot";
    script = ''
      ${startStopped}
      if [ "$startFailed" != "0" ]; then
        ${sendMail "Stack restart after interrupted backup failed" "See ${stoppedList}."}
        exit 1
      fi
    '';
  };
}
