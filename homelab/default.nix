{
  lib,
  config,
  ...
}: let
  cfg = config.homelab;
in {
  options.homelab = {
    enable = lib.mkEnableOption "The homelab services and configuration variables";
    user = lib.mkOption {
      default = "share";
      type = lib.types.str;
      description = ''
        User to run the homelab services as
      '';
    };
    group = lib.mkOption {
      default = "share";
      type = lib.types.str;
      description = ''
        Group to run the homelab services as
      '';
    };
    timeZone = lib.mkOption {
      default = "Europe/Rome";
      type = lib.types.str;
      description = ''
        Time zone to be used for the homelab services
      '';
    };
    baseDomain = lib.mkOption {
      default = "dimoracosta.it";
      type = lib.types.str;
      description = ''
        Base domain name to be used to access the homelab services via Caddy reverse proxy
      '';
    };
  };
  imports = [
    ./services
  ];
  config = lib.mkIf cfg.enable {
    users = {
      groups.${cfg.group} = {
        gid = 993;
      };
      users.${cfg.user} = {
        uid = 994;
        isSystemUser = true;
        group = cfg.group;
      };
    };

    # Power
    powerManagement.cpuFreqGovernor = "powersave";
    services.thermald.enable = true;

    # Turn off every night at 2AM
    systemd.timers."goodnight" = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "*-*-* 02:00:00";
        AccuracySec = "1min";
        Persistent = false;
      };
    };

    systemd.services."goodnight" = {
      script = ''
        /run/current-system/sw/bin/shutdown now
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };
}
