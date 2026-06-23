{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.jellyseerr;
  homelab = config.homelab;
in {
  options.homelab.services.jellyseerr = {
    enable = lib.mkEnableOption "Enable Jellyseerr";
    url = lib.mkOption {
      type = lib.types.str;
      default = "req.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 5055;
    };
  };
  config = lib.mkIf cfg.enable {
    services.jellyseerr = {
      enable = true;
      port = cfg.port;
    };

    systemd.services.jellyseerr = {
      wants = ["newt.service"];
    };
  };
}
