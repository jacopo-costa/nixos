{...}: {
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

  # Swap
  swapDevices = [
    {
      device = "/swapfile";
      size = 12 * 1024;
    }
  ];

  # System
  system.stateVersion = "26.05";
}
