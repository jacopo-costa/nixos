{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./desktop
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  swapDevices = [
    {
      device = "/swapfile";
      size = 12 * 1024;
    }
  ];

  hardware.cpu.amd.updateMicrocode = true;

  boot = {
    initrd = {
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_usb_sdmmc"];
      kernelModules = ["amdgpu"];
    };
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
  };

  # Set hostname
  networking.hostName = "librovivo";

  # Enable host specific services
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
}
