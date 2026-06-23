{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.lidarr;
  homelab = config.homelab;
in {
  options.homelab.services.lidarr = {
    enable = lib.mkEnableOption "Lidarr music manager";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8686;
    };
  };

  config = lib.mkIf cfg.enable {
    services.lidarr = {
      enable = true;
      group = homelab.group;
      settings.server.port = cfg.port;
    };
  };
}
