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
    intel = lib.mkEnableOption "Intel-specific hardware support";
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

    boot = {
      # TCP tuning
      kernelModules = ["tcp_bbr"];
      # Enable L1 + L1 substates where both link ends support it; no `force` (kernel docs: may cause lockups)
      kernelParams = ["pcie_aspm.policy=powersupersave"];
    };

    # intel_pstate HWP energy/performance hint: favour power over performance
    systemd.tmpfiles.rules = lib.mkIf cfg.intel [
      "w /sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference - - - - balance_power"
    ];

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
      virt-manager
    ];

    # Spin down rotational sd* disks after 10 minutes idle (no -B: the pool's drives lack APM)
    # Turn off WoL
    services.udev.extraRules = ''
      ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", RUN+="${pkgs.hdparm}/bin/hdparm -S 120 /dev/%k"
      ACTION=="add", SUBSYSTEM=="net", DRIVERS=="?*", ATTR{device/subsystem}=="pci", RUN+="${pkgs.ethtool}/bin/ethtool -s %k wol d"
    '';

    # SMARTd
    services.smartd = {
      enable = true;
      # Tests missed while in standby run at the next awake check; only the skip cap (48 x 30min = 1/day) forces a spin-up.
      # Short: Monday 03:00 (disks already up for borg). Long: 15th, away from the monthly scrub on the 1st.
      defaults.autodetected = "-a -o on -S on -s (S/../../1/03|L/../15/./03) -n standby,48,q";

      notifications = lib.mkIf config.email.enable {
        mail = {
          enable = true;
          sender = config.email.fromAddress;
          recipient = config.email.toAddress;
        };
      };
    };

    services = {
      # Intel-specific services
      thermald = lib.mkIf cfg.intel {
        enable = true;
      };
    };

    # Virtualisation
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          runAsRoot = true;
          swtpm.enable = true;
        };

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
          # Docker's built-in pools run out of 172.x after 15 networks and fall back to 192.168.0.0/16 (LAN clash)
          default-address-pools = [
            {
              base = "172.16.0.0/12";
              size = 24;
            }
          ];
        };
      };
    };
  };
}
