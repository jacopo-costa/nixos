{
  lib,
  pkgs,
  ...
}: {
  desktop = {
    enable = true;
    loader = "grub";
    intel = false;
  };

  # Boot
  boot = {
    initrd = {
      systemd.enable = true;
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];

      kernelModules = ["amdgpu"];
    };
    # Reduce swappiness
    kernel.sysctl."vm.swappiness" = 10;
  };

  # Hardware
  hardware = {
    cpu.amd.updateMicrocode = true;
  };

  # Networking
  networking = {
    hostName = "cooler";
  };

  # Pkgs
  environment = {
    systemPackages = with pkgs; [
      openrgb
      mangohud

      nodejs
    ];
  };

  # Programs
  programs = {
    # Gaming
    steam = {
      enable = true;
      package = pkgs.steam.override {
        extraPkgs = p: [
          p.kdePackages.breeze
          # Need python for the widescreen fix on Elden Ring
          p.python314
        ];
        extraEnv = {
          GAMEMODERUN = "1";
          MANGOHUD = "1";
        };
      };
    };
    gamemode.enable = true;
  };

  # Services
  services = {
    hardware.openrgb.enable = true;

    # Ollama
    ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
      host = "[::]";
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
  system.stateVersion = "26.05";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
