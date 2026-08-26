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
    grub = lib.mkEnableOption "GRUB boot loader";
    systemd-boot = lib.mkEnableOption "systemd-boot boot loader";
    intel = lib.mkEnableOption "Intel-specific hardware support";
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.grub != cfg.systemd-boot;
        message = "Exactly one of desktop.grub or desktop.systemd-boot must be enabled.";
      }
    ];

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
        grub = lib.mkIf cfg.grub {
          enable = true;
          devices = ["nodev"];
          efiSupport = true;
          useOSProber = true;
          # Set to default the Windows boot entry
          default = "2";
        };

        # Systemd boot
        systemd-boot = lib.mkIf cfg.systemd-boot {
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
