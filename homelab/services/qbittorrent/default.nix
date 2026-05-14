{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.qbittorrent;
  homelab = config.homelab;
in {
  options.homelab.services.deluge = {
    enable = lib.mkEnableOption "qBittorrent torrent client";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8090;
    };
  };
  config = lib.mkIf cfg.enable {
    services.qbittorrent = {
      enable = true;
      user = homelab.user;
      group = homelab.group;
      webuiPort = cfg.port;
      openFirewall = true;
    };
  };
}
