{lib, ...}: {
  desktop = {
    enable = true;
    loader = "systemd-boot";
  };

  # Boot
  boot = {
    initrd = {
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_usb_sdmmc"];
      kernelModules = ["amdgpu"];
      systemd.enable = true;
    };
    kernelParams = ["amd_pstate=active"];
    kernelModules = ["kvm-amd"];
  };

  # Italian keymap at the LUKS prompt (and post-boot console)
  console.keyMap = "it";

  # Hardware
  hardware.cpu.amd.updateMicrocode = true;

  # Networking
  networking.hostName = "librovivo";

  # Services
  services.tlp = {
    enable = true;

    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
      DISK_IDLE_TIMEOUT = 15;
      USB_AUTOSUSPEND = 1;
    };
  };

  # Swap
  swapDevices = [
    {
      device = "/swapfile";
      size = 12 * 1024;
    }
  ];

  # System
  system.stateVersion = "26.05";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
