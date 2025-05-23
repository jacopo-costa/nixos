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

  services.hardware.openrgb.enable = true;

  environment.systemPackages = with pkgs; [
    openrgb
  ];

  programs = {
    # Gaming
    steam = {
      package = pkgs.steam.override {
        extraPkgs = p: [
          p.kdePackages.breeze
        ];
      };
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
    };
    gamemode.enable = true;
  };
}
