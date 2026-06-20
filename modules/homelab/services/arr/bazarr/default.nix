{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.bazarr;
  homelab = config.homelab;
in {
  options.homelab.services.bazarr = {
    enable = lib.mkEnableOption "Bazarr subtitle manager";
    port = lib.mkOption {
      type = lib.types.port;
      default = 6767;
    };
  };

  config = lib.mkIf cfg.enable {
    services.bazarr = {
      enable = true;
      user = homelab.user;
      group = homelab.group;
      listenPort = cfg.port;
    };
  };
}
