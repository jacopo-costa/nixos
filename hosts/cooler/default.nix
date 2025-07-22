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
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
      # Make the kernel use the correct driver early
      kernelModules = ["amdgpu"];
    };
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
  };

  # Hardware
  hardware = {
    cpu.amd.updateMicrocode = true;

    # OpenGL
    graphics.extraPackages = with pkgs; [
      rocmPackages.clr.icd
      amdvlk
    ];
  };

  # Networking
  networking = {
    hostName = "cooler";
  };

  # Pkgs
  environment = {
    systemPackages = with pkgs; [
      openrgb
      gimp
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

    ollama = {
      enable = true;
      acceleration = "rocm";
    };

    # Enable streaming
    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
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
  system.autoUpgrade.allowReboot = lib.mkForce false;

  # Virtualization
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["jacopo"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
}
