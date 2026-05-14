{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.flaresolverr;
  homelab = config.homelab;
in {
  options.homelab.services.flaresolverr = {
    enable = lib.mkEnableOption {
      description = "Enable Flaresolverr";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8191;
    };
  };
  config = lib.mkIf cfg.enable {
    services.flaresolverr = {
      enable = true;
      port = cfg.port;
    };
  };
}
