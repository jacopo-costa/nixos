{...}: {
  imports = [
    ./backup
    ./email
    ./network
    ./zfs
  ];

  # Boot
  boot = {
    initrd = {
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod"];
      kernelModules = [];
    };
    kernelModules = ["kvm-intel"];

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        editor = false;
      };
    };

    # ZFS
    supportedFilesystems = ["zfs"];
    zfs = {
      extraPools = ["tank"];
      forceImportRoot = false;
    };
  };

  # Hardware
  hardware.cpu.intel.updateMicrocode = true;

  # Homelab
  homelab = {
    enable = true;
    user = "ice";
    group = "ice";
    intel = true;
  };

  # Virtualisation
  virtualisation.libvirtd.allowedBridges = ["br0"];

  # Stacks bind-mount /mnt/tank: never start Docker without the pool, or `-v` creates empty dirs on root
  systemd.services.docker = {
    requires = ["zfs-import-tank.service"];
    after = ["zfs-import-tank.service" "zfs-mount.service"];
  };

  # Traefik access log (stacks/traefik)
  services.logrotate.settings.traefik-access = {
    files = "/var/lib/docker/volumes/traefik_logs/_data/access.log";
    frequency = "daily";
    rotate = 7;
    compress = true;
    delaycompress = true;
    missingok = true;
    notifempty = true;
    copytruncate = true;
  };

  # Services
  services.openssh = {
    enable = true;
    ports = [22];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AllowUsers = ["jacopo"];
      PermitRootLogin = "no";
    };
  };

  # Swap
  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024;
    }
  ];

  # System
  system.stateVersion = "26.05";
}
