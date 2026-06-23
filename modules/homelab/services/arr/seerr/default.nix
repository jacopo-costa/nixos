{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.seerr;
  homelab = config.homelab;
in {
  options.homelab.services.seerr = {
    enable = lib.mkEnableOption "Enable Seerr";
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
    services.seerr = {
      enable = true;
      port = cfg.port;
    };

    systemd.services.seerr = {
      wants = ["newt.service"];
    };
  };
}
