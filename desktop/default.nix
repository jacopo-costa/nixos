{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.desktop;
in {
  options.desktop = {
    enable = lib.mkEnableOption "The desktop services and configuration variables";
    grub = lib.mkEnableOption "Whether to activate grub";
    systemd-boot = lib.mkEnableOption "Whether to activate systemd-boot";
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
        grub = lib.mkIf cfg.grub {
          enable = true;
          devices = ["nodev"];
          efiSupport = true;
          useOSProber = true;
          default = "2";
        };

        # Systemd boot
        systemd-boot = lib.mkIf cfg.systemd-boot {
          enable = true;
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
        "splash"
        "boot.shell_on_fail"
        "udev.log_priority=3"
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
      # Multimedia
      spotify
      vlc
      # Spelling
      aspell
      aspellDicts.it
      aspellDicts.en
      # KDE Utilities
      kdePackages.kcalc
      kdePackages.sddm-kcm
      kdePackages.partitionmanager
      # Cloud
      nextcloud-client
    ];

    # Power management
    powerManagement.enable = true;

    # Programs
    programs = {
      # Firefox
      firefox = {
        enable = true;
        preferences = {
          "widget.use-xdg-desktop-portal.file-picker" = 1;
        };
      };
    };

    # Services
    services = {
      # Enable X11
      xserver = {
        enable = true;
      };

      # Enable Plasma and SDDM
      desktopManager.plasma6.enable = true;
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };

      # Enable CUPS to print documents.
      printing.enable = true;

      # Enable thermald
      thermald.enable = true;
    };
  };
}
