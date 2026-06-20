{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.sonarr;
  homelab = config.homelab;
in {
  options.homelab.services.sonarr = {
    enable = lib.mkEnableOption "Enable Sonarr";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8989;
    };
  };
  config = lib.mkIf cfg.enable {
    services.sonarr = {
      enable = true;
      settings.server.port = cfg.port;
      user = homelab.user;
      group = homelab.group;
    };
  };
}
