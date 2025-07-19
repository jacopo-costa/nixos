{config, ...}: let
  de = config.desktop;
in {
  desktop = {
    enable = true;
    grub = true;
    systemd-boot = false;
  };
}
