{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./network.nix
    ./homelab
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  boot = {
    initrd = {
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod"];
      kernelModules = [];
    };
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];

    loader = {
      # Systemd boot
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };

    # ZFS
    supportedFilesystems = ["zfs"];
    zfs.extraPools = ["tank"];
  };

  # Hardware acceleration for jellyfin
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
  };
  hardware = {
    cpu.intel.updateMicrocode = true;
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        vaapiVdpau
        libvdpau-va-gl
        intel-compute-runtime
        vpl-gpu-rt
      ];
    };
  };

  sops = {
    secrets = {
      smtpPassword = {};
    };
  };

  email = {
    enable = true;
    fromAddress = "dimoracosta.system@gmail.com";
    toAddress = "costa.jacopo@gmail.com";
    smtpServer = "smtp.gmail.com";
    smtpPort = 587;
    smtpUsername = "dimoracosta.system@gmail.com";
    smtpPasswordPath = config.sops.secrets.smtpPassword.path;
  };

  services.zfs.zed.settings = {
    ZED_DEBUG_LOG = "/tmp/zed.debug.log";
    ZED_EMAIL_ADDR = ["root"];
    ZED_EMAIL_PROG = "sendmail";
    ZED_EMAIL_OPTS = "@ADDRESS@";

    ZED_NOTIFY_INTERVAL_SECS = 3600;
    ZED_NOTIFY_VERBOSE = true;

    ZED_USE_ENCLOSURE_LEDS = true;
    ZED_SCRUB_AFTER_RESILVER = true;
  };
}
