{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./email
    ./homelab
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
      # Systemd boot
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };

    # ZFS
    supportedFilesystems = ["zfs"];
    zfs.extraPools = ["tank"];
  };

  # Hardware
  hardware = {
    cpu.intel.updateMicrocode = true;
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
        intel-compute-runtime
        vpl-gpu-rt
      ];
    };
  };

  # Services
  services.openssh = {
    enable = true;
    ports = [22];
    settings = {
      PasswordAuthentication = false;
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
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
