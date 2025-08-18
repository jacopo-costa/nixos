{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.homelab;
in {
  # Options
  options.homelab = {
    enable = lib.mkEnableOption "The homelab services and configuration variables";
    user = lib.mkOption {
      default = "ice";
      type = lib.types.str;
      description = ''
        User to run the homelab services as
      '';
    };
    group = lib.mkOption {
      default = "ice";
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
    # Share user
    users = {
      groups.${cfg.group} = {
        gid = 950;
      };
      users.${cfg.user} = {
        uid = 950;
        isSystemUser = true;
        group = cfg.group;
      };
    };

    # Power Managment
    powerManagement = {
      enable = true;
      cpuFreqGovernor = "powersave";
      powertop.enable = true;
    };
    services.thermald.enable = true;

    environment.systemPackages = with pkgs; [
      powertop
      hdparm
      smartmontools
    ];

    # Activate power save on any sd* disks and spindown after 10 minutes
    services.udev.extraRules = let
      mkRule = as: lib.concatStringsSep ", " as;
      mkRules = rs: lib.concatStringsSep "\n" rs;
    in
      mkRules [
        (mkRule [
          ''ACTION=="add|change"''
          ''SUBSYSTEM=="block"''
          ''KERNEL=="sd[a-z]"''
          ''ATTR{queue/rotational}=="1"''
          ''RUN+="${pkgs.hdparm}/bin/hdparm -B 90 -S 120 /dev/%k"''
        ])
      ];

    # SMARTd
    services.smartd = {
      enable = true;
      defaults.autodetected = "-a -o on -S on -s (S/../.././10|L/../../7/11) -n standby,q";

      notifications = {
        mail = {
          enable = true;
          sender = config.email.fromAddress;
          recipient = config.email.toAddress;
        };
      };
    };

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
