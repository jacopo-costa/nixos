{
  config,
  pkgs,
  home-manager,
  ...
}: {
  imports = [
    home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ../../modules/desktop

    # Users
    ../../users/jacopo
  ];

  # Set hostname
  networking.hostName = "cooler";

  # Enable host specific services
  services = {
    xserver.videoDrivers = ["amdgpu"];

    # Enable automatic login for the user.
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "jacopo";

    # Configure keymap in X11
    xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };
}
