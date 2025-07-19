{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  system.stateVersion = "25.05";
  system.autoUpgrade = {
    enable = true;
    flake = "/etc/nixos\\?submodules=1";
    flags = [
      "--update-input"
      "nixpkgs"
      "-L"
    ];
    dates = "Sat *-*-* 09:00:00";
    randomizedDelaySec = "45min";
    allowReboot = true;
  };

  imports = [
    ./nix
    ./secrets
  ];

  time.timeZone = "Europe/Rome";

  # Default IT locale
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

  programs.git.enable = true;
  programs.htop.enable = true;
  programs.zsh.enable = true;

  security = {
    doas.enable = lib.mkDefault false;
    sudo = {
      enable = lib.mkDefault true;
      wheelNeedsPassword = lib.mkDefault false;
    };
  };

  environment.systemPackages = with pkgs; [
    wget
    lm_sensors
  ];
}
