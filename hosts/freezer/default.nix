{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./backup
    ./email
    ./network
    ./zfs
  ];

  # Boot
  boot = {
    initrd = {
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod"];
      kernelModules = [];
    };
    kernelModules = ["kvm-intel"];

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        editor = false;
      };
    };

    # ZFS
    supportedFilesystems = ["zfs"];
    zfs = {
      extraPools = ["tank"];
      forceImportRoot = false;
    };
  };

  # Hardware
  hardware.cpu.intel.updateMicrocode = true;

  # Jellyfin transcoding dependencies (VA-API / QuickSync only)
  environment.systemPackages = with pkgs; [
    intel-media-driver
    libva-utils
  ];

  # Homelab
  homelab = {
    enable = true;
    user = "ice";
    group = "ice";
    intel = true;
  };

  # Virtualisation
  virtualisation.libvirtd.allowedBridges = ["br0"];

  # Services
  services.openssh = {
    enable = true;
    ports = [22];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AllowUsers = ["jacopo"];
      PermitRootLogin = "no";
    };
  };

  # Swap
  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024;
    }
  ];

  # System
  system.stateVersion = "26.05";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
