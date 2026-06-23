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
    mainUser = lib.mkOption {
      default = "jacopo";
      type = lib.types.str;
      description = ''
        Main user to add in the homelab group
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
        Base domain for external access via Pangolin.
      '';
    };
    localDomain = lib.mkOption {
      default = "freezer.lan";
      type = lib.types.str;
      description = ''
        Local LAN domain used by the nginx reverse proxy for internal access.
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
      users = {
        ${cfg.user} = {
          uid = 950;
          isSystemUser = true;
          group = cfg.group;
        };
        ${cfg.mainUser}.extraGroups = [cfg.group];
      };
    };

    # Power Management
    powerManagement = {
      enable = true;
      powertop.enable = true;
      cpuFreqGovernor = "powersave";
    };
    boot.kernelParams = ["pcie_aspm=force" "pcie_aspm.policy=powersupersave"];

    environment.systemPackages = with pkgs; [
      powertop
      hdparm
      smartmontools
    ];

    # Activate power save on any sd* disks and spindown after 10 minutes
    # Turn off WoL
    services.udev.extraRules = ''
      ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", RUN+="${pkgs.hdparm}/bin/hdparm -B 90 -S 120 /dev/%k"
      ACTION=="add", SUBSYSTEM=="net", RUN+="${pkgs.ethtool}/bin/ethtool -s %k wol d"
    '';

    # SMARTd
    services.smartd = {
      enable = true;
      defaults.autodetected = "-a -o on -S on -s (S/../.././10|L/../../7/11) -n standby,q";

      notifications = lib.mkIf config.email.enable {
        mail = {
          enable = true;
          sender = config.email.fromAddress;
          recipient = config.email.toAddress;
        };
      };
    };

    security.apparmor.enable = true;

    # Virtualisation
    virtualisation = {
      libvirtd = {
        enable = true;

        onBoot = "start";
        onShutdown = "shutdown";
      };
    };
  };
}
