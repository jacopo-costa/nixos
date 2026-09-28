{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.desktop;
in {
  options.desktop = {
    enable = lib.mkEnableOption "desktop services and configuration";
    loader = lib.mkOption {
      default = null;
      type = lib.types.nullOr (lib.types.enum ["grub" "systemd-boot"]);
      description = ''
        Boot loader to use. Set to null if the host manages its own boot loader.
      '';
    };
    intel = lib.mkEnableOption "Intel-specific hardware support";
  };

  config = lib.mkIf cfg.enable {
    # Audio
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Boot
    boot = {
      loader = {
        efi.canTouchEfiVariables = true;

        # GRUB
        grub = lib.mkIf (cfg.loader == "grub") {
          enable = true;
          devices = ["nodev"];
          efiSupport = true;
          useOSProber = true;
          # Set to default the Windows boot entry
          default = "2";
        };

        # Systemd boot
        systemd-boot = lib.mkIf (cfg.loader == "systemd-boot") {
          enable = true;
          editor = false;
        };
      };

      plymouth = {
        enable = true;
      };

      # Enable "Silent boot"
      consoleLogLevel = 3;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "rd.udev.log_level=3"
        "rd.systemd.show_status=auto"
      ];

      # Reduce swappiness
      kernel.sysctl."vm.swappiness" = 10;
    };

    # Hardware
    hardware = {
      bluetooth.enable = true;

      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };

    # Networking
    networking = {
      networkmanager.enable = true;
    };

    # Pkgs
    environment.systemPackages = with pkgs; [
      # Spelling
      aspell
      aspellDicts.it
      aspellDicts.en

      # KDE Utilities
      kdePackages.kcalc
      kdePackages.partitionmanager

      # Equalizer
      easyeffects
    ];

    # Power management
    powerManagement.enable = true;

    # Flatpak
    services.flatpak.enable = true;
    systemd.services.flatpak-repo = {
      wantedBy = ["multi-user.target"];
      path = [pkgs.flatpak];
      script = ''
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      '';
    };

    # Services
    services = {
      # Enable Plasma and login manager
      desktopManager.plasma6.enable = true;
      displayManager.plasma-login-manager.enable = true;

      # Printing
      printing.enable = true;

      # Intel-specific services
      thermald = lib.mkIf cfg.intel {
        enable = true;
      };
    };
  };
}
