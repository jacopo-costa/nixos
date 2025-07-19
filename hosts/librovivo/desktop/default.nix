{config, ...}: let
  de = config.desktop;
in {
  desktop = {
    enable = true;
    grub = false;
    systemd-boot = true;
  };
}
