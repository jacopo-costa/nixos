{
  config,
  lib,
  ...
}: let
  service = "prowlarr";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in {
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 9696;
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      settings.server.port = cfg.port;
      openFirewall = true;
    };
  };
}
