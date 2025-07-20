{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./desktop
  ];
  # Set hostname
  networking = {
    hostName = "cooler";
  };

  # GRUB
  boot = {
    initrd = {
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
      # Make the kernel use the correct driver early
      kernelModules = ["amdgpu"];
    };
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
  };

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

  hardware = {
    cpu.amd.updateMicrocode = true;

    # OpenGL
    graphics.extraPackages = with pkgs; [
      rocmPackages.clr.icd
      amdvlk
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      openrgb
      gimp
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

  system.autoUpgrade.allowReboot = lib.mkForce false;

  # Virtualization
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["jacopo"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
}
