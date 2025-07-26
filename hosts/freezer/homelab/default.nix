{config, ...}: let
  hl = config.homelab;
in {
  homelab = {
    enable = true;
    timeZone = "Europe/Rome";
    services = {
      enable = true;
      containerizationType = "docker";
    };
  };
}
