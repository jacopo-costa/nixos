{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.radarr;
  homelab = config.homelab;
in {
  options.homelab.services.radarr = {
    enable = lib.mkEnableOption "Enable Radarr";
    port = lib.mkOption {
      type = lib.types.port;
      default = 7878;
    };
  };
  config = lib.mkIf cfg.enable {
    services.radarr = {
      enable = true;
      group = homelab.group;
      settings.server.port = cfg.port;
    };
  };
}
