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
    intel = lib.mkEnableOption "If it's an Intel machine";
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
          # Set to default the Windows boot entry
          default = "Windows Boot Manager";
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
      # Spelling
      aspell
      aspellDicts.it
      aspellDicts.en
      # KDE Utilities
      kdePackages.kcalc
      kdePackages.sddm-kcm
      kdePackages.partitionmanager
    ];

    # Power management
    powerManagement.enable = true;

    # Flatpak
    services.flatpak.enable = true;
    systemd.services.flatpak-repo = {
      wantedBy = ["multi-user.target"];
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      path = [pkgs.flatpak];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
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

      # Enable thermald only if it's an Intel machine
      thermald = lib.mkIf cfg.intel {
        enable = true;
      };
    };
  };
}
