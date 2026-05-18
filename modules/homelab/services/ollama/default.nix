{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.ollama;
  homelab = config.homelab;
in {
  options.homelab.services.ollama = {
    enable = lib.mkEnableOption {
      description = "Enable ollama";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 11434;
    };
  };
  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      port = cfg.port;
      openFirewall = true;
    };
  };
}
