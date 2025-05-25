{
  # GRUB config designed for Cooler, it shouldn't be here but oh well...
  # It default to the second entry (should be Windows) and enable silent boot.
  # It also add amdgpu module to the kernel.
  boot = {
    loader.efi.canTouchEfiVariables = true;
    loader.grub = {
      enable = true;
      devices = ["nodev"];
      efiSupport = true;
      useOSProber = true;
      default = "2";
    };
  };
}
