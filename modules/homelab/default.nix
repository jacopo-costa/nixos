{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./boot.nix
    ./traefik.nix
    ./services.nix
  ];

  # Firewall
  networking.firewall = {
    enable = true;
  };

  # Power
  powerManagement.cpuFreqGovernor = "powersave";
  services.thermald.enable = true;

  # Shell
  programs.zsh.enable = true;

  # Users/Groups
  users.mutableUsers = true;
  users.groups = {
    # Create multimedia group
    arr = {};
  };

  system.stateVersion = "25.05";
}
