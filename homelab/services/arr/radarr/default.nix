{
  config,
  lib,
  ...
}: let
  service = "radarr";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in {
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 7878;
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      settings.server.port = cfg.port;
      openFirewall = true;
      user = homelab.user;
      group = homelab.group;
    };
  };
}
