{
  config,
  lib,
  ...
}: let
  service = "deluge";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in {
  options.homelab.services.deluge = {
    enable = lib.mkEnableOption "Deluge torrent client";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8112;
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      user = homelab.user;
      group = homelab.group;
      web = {
        enable = true;
        port = cfg.port;
        openFirewall = true;
      };
    };
  };
}
