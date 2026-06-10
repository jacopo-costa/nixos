{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./nix
    ./secrets
  ];

  boot.kernel.sysctl = {
    # No kernel pointer leaks to userspace
    "kernel.kptr_restrict" = 2;
    # dmesg only for root
    "kernel.dmesg_restrict" = 1;
    # Don't let userspace see /proc/<pid> of other users
    # (caution: breaks some monitoring tools — test)
    # "kernel.yama.ptrace_scope" = 2;

    # Reverse path filter (drop spoofed source addresses)
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    # SYN cookie defense against SYN flood
    "net.ipv4.tcp_syncookies" = 1;
    # Ignore ICMP redirects (limits MitM via rogue routers)
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    # Don't accept source-routed packets
    "net.ipv4.conf.all.accept_source_route" = 0;
  };

  # Firmware update
  services.fwupd.enable = true;

  # Hardware
  hardware = {
    enableRedistributableFirmware = true;
  };

  # Locale
  i18n.defaultLocale = "it_IT.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Pkgs
  environment.systemPackages = with pkgs; [
    wget
    lm_sensors
  ];

  # Programs
  programs = {
    git.enable = true;
    htop.enable = true;
    zsh.enable = true;
  };

  # Security
  security = {
    sudo = {
      enable = lib.mkDefault true;
      wheelNeedsPassword = lib.mkDefault true;
    };
  };

  # System
  system = {
    stateVersion = "26.05";
  };

  # Timezone
  time.timeZone = "Europe/Rome";

  # Users
  # set mutable as false because
  # the password is already set as hashable
  users.mutableUsers = false;
}
