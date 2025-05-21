{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ../modules/locale.nix
    ../modules/grub.nix
    ../modules/sound.nix
    ../modules/system.nix

    # Users
    ../users/jacopo
  ];

  hardware = {
    bluetooth.enable = true;
  };

  # Networking
  networking = {
    hostName = "cooler";
    networkmanager.enable = true;
  };

  services = {
    # Enable X11
    xserver = {
      enable = true;
      videoDrivers = ["amdgpu"];
    };

    # Enable Plasma and SDDM
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;

    # Enable automatic login for the user.
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "jacopo";

    # Configure keymap in X11
    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Enable CUPS to print documents.
    printing.enable = true;
  };

  # Programs
  programs = {
    firefox = {
      enable = true;
      preferences = {
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };
    };

    steam = {
      package = pkgs.steam.override {
        extraPkgs = p: [
          p.kdePackages.breeze
        ];
      };
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Home Manager
    # home-manager
    git
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        brettm12345.nixfmt-vscode
        bbenoist.nix
        jnoortheen.nix-ide
      ];
    })
    nixfmt-rfc-style
    spotify
    vlc
    # Spelling
    aspell
    aspellDicts.it
    aspellDicts.en
  ];
}
