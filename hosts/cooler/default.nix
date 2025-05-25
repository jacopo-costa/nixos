{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop

    ../../modules/grub.nix
    ../../modules/locale.nix

    # Users
    ../../users/jacopo
  ];

  # Set hostname
  networking.hostName = "cooler";

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
      layout = "us";
      variant = "";
    };

    hardware.openrgb.enable = true;
  };

  # OpenCL
  hardware = {
    opengl.extraPackages = with pkgs; [
      rocmPackages.clr.icd
      amdvlk
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      openrgb
      # OpenCL
      clinfo
    ];
  };

  programs = {
    # Gaming
    steam = {
      package = pkgs.steam.override {
        extraPkgs = p: [
          p.kdePackages.breeze
          p.python314
        ];
      };
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
    };
    gamemode.enable = true;
  };
}
