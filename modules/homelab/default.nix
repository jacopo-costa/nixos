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
  };

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

    # TCP tuning
    boot = {
      kernelModules = ["tcp_bbr"];
      kernelParams = ["pcie_aspm=force" "pcie_aspm.policy=powersupersave"];

      kernel.sysctl = {
        "net.core.rmem_max"          = 134217728;  # 128 MiB
        "net.core.wmem_max"          = 134217728;
        "net.ipv4.tcp_rmem"          = "4096 87380 134217728";
        "net.ipv4.tcp_wmem"          = "4096 65536 134217728";
        "net.core.netdev_max_backlog" = 5000;
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.default_qdisc"     = "fq";       # required for BBR
      };
    };

    # Power Management
    powerManagement = {
      enable = true;
      powertop.enable = true;
      cpuFreqGovernor = "powersave";
    };

    environment.systemPackages = with pkgs; [
      powertop
      hdparm
      smartmontools
    ];

    # Activate power save on any sd* disks and spindown after 10 minutes
    # Turn off WoL
    services.udev.extraRules = ''
      ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", RUN+="${pkgs.hdparm}/bin/hdparm -B 90 -S 120 /dev/%k"
      ACTION=="add", SUBSYSTEM=="net", DRIVERS=="?*", ATTR{device/subsystem}=="pci", RUN+="${pkgs.ethtool}/bin/ethtool -s %k wol d"
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

    # Virtualisation
    virtualisation = {
      libvirtd = {
        enable = true;

        onBoot = "start";
        onShutdown = "shutdown";
      };

      # Every app is in a docker compose under /srv/stacks
      docker = {
        enable = true;
        autoPrune.enable = true;
        daemon.settings = {
          userland-proxy = false;
          ipv6 = false;
          no-new-privileges = true;
        };
      };
    };
  };
}
