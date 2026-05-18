{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./desktop
  ];

  # Boot
  boot = {
    initrd = {
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_usb_sdmmc"];
      kernelModules = ["amdgpu"];
    };
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
  };

  # Hardware
  hardware.cpu.amd.updateMicrocode = true;

  # Networking
  networking.hostName = "librovivo";

  # Services
  services = {
    xserver.videoDrivers = ["amdgpu"];

    # Enable automatic login for the user.
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "jacopo";

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
