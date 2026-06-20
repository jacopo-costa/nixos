{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.prowlarr;
  homelab = config.homelab;
in {
  options.homelab.services.prowlarr = {
    enable = lib.mkEnableOption "Enable Prowlarr";
    port = lib.mkOption {
      type = lib.types.port;
      default = 9696;
    };
  };
  config = lib.mkIf cfg.enable {
    services.prowlarr = {
      enable = true;
      settings.server.port = cfg.port;
    };
  };
}
