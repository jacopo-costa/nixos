{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./nix
    ./secrets
  ];

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
    stateVersion = "25.11";
  };

  # Timezone
  time.timeZone = "Europe/Rome";

  # Users
  # set mutable as false because
  # the password is already set as hashable
  users.mutableUsers = false;
}
