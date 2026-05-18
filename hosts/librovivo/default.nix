{
  config,
  lib,
  pkgs,
  ...
}: {
  desktop = {
    enable = true;
    grub = false;
    systemd-boot = true;
  };

  # Boot
  boot = {
    initrd = {
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_usb_sdmmc"];
      kernelModules = ["amdgpu"];
      # systemd-style initrd: honors console.keyMap at the LUKS prompt
      # and is required for future TPM2 / FIDO2 unlock.
      systemd.enable = true;
    };
    kernelModules = ["kvm-amd"];
  };

  # Italian keymap at the LUKS prompt (and post-boot console)
  console.keyMap = "it";

  # Hardware
  hardware.cpu.amd.updateMicrocode = true;

  # Networking
  networking.hostName = "librovivo";

  # Services
  services = {
    xserver.videoDrivers = ["amdgpu"];

    # Configure keymap in X11
    xserver.xkb = {
      layout = "it";
      variant = "";
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
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
