{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop

    ../../modules/systemd-boot.nix
    ../../modules/locale.nix

    # Users
    ../../users/jacopo
  ];

  # Set hostname
  networking.hostName = "librovivo";

  # Make the kernel use the correct driver early
  boot.initrd.kernelModules = ["amdgpu"];

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
