{
  # Bootloader.
  boot = {
    loader.efi.canTouchEfiVariables = true;
    loader.grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
      default = "2";
    };

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd = {
      verbose = false;
      kernelModules = [ "amdgpu" ];
    };

    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
  };
}
