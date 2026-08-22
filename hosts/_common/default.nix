{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./nix
    ./secrets
  ];

  services = {
    # Firmware update
    fwupd.enable = true;
    # IRQ affinity management
    irqbalance.enable = true;
  };

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
    zsh.enable = true;
    htop.enable = true;
    git.enable = true;
  };

  # Security
  security = {
    sudo = {
      enable = lib.mkDefault true;
      wheelNeedsPassword = lib.mkDefault true;
    };
  };

  # Timezone
  time.timeZone = "Europe/Rome";

  # Users
  # set mutable as false because
  # the password is already set as hashed
  users.mutableUsers = false;
}
