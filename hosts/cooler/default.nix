{pkgs, ...}: {
  desktop = {
    enable = true;
    loader = "grub";
    intel = false;
  };

  # Boot
  boot = {
    initrd = {
      systemd.enable = true;
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid"];

      kernelModules = ["amdgpu"];
    };
    kernelModules = ["kvm-amd"];
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
      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];
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
      environmentVariables = {
        OLLAMA_CONTEXT_LENGTH = "16384";
        OLLAMA_NUM_PARALLEL = "1";
        OLLAMA_MAX_LOADED_MODELS = "1";
        OLLAMA_FLASH_ATTENTION = "1";
        OLLAMA_KV_CACHE_TYPE = "q8_0";
        OLLAMA_KEEP_ALIVE = "5m";
      };
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
}
