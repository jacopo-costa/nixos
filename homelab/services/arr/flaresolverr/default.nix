{
  pkgs,
  config,
  lib,
  ...
}: let
  service = "flaresolverr";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in {
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
    };
  };
}
