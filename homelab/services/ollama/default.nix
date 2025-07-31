{
  config,
  pkgs,
  lib,
  ...
}: let
  service = "ollama";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in {
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 11434;
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      port = cfg.port;
      openFirewall = true;
    };
  };
}
