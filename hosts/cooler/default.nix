{
  lib,
  pkgs,
  ...
}: {
  desktop = {
    enable = true;
    grub = true;
    systemd-boot = false;
  };

  # Boot
  boot = {
    initrd = {
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
    };
    kernelModules = ["kvm-amd"];
  };

  # Hardware
  hardware = {
    cpu.amd.updateMicrocode = true;
    amdgpu.initrd.enable = true;

    # OpenGL
    graphics.extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };

  # Networking
  networking = {
    hostName = "cooler";
  };

  # Pkgs
  environment = {
    systemPackages = with pkgs; [
      protonup-qt
      openrgb
    ];
  };

  # Programs
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

  # Services
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
    lact.enable = true;

    # AI
    ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
      # results in environment variable "HSA_OVERRIDE_GFX_VERSION=11.0.0"
      rocmOverrideGfx = "11.0.0";
    };
  };

  # Swap
  swapDevices = [
    {
      device = "/swapfile";
      size = 32 * 1024;
    }
  ];

  # System
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
