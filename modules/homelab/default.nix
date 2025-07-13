{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./boot.nix
    ./postfix.nix
    ./services
    ./smartd.nix
    ./traefik.nix
  ];

  # Firewall
  networking.firewall = {
    enable = true;
  };

  # Power
  powerManagement.cpuFreqGovernor = "powersave";
  services.thermald.enable = true;

  # Turn off every night at 2AM
  systemd.timers."goodnight" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 02:00:00";
      AccuracySec = "1min";
      Persistent = false;
    };
  };

  systemd.services."goodnight" = {
    script = ''
      /run/current-system/sw/bin/shutdown now
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

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
