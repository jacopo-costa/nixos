{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.sabnzbd;
  homelab = config.homelab;
in {
  options.homelab.services.sabnzbd = {
    enable = lib.mkEnableOption "SABnzbd Usenet downloader";
    port = lib.mkOption {
      type = lib.types.port;
      default = 6789;
      description = "Port SABnzbd listens on (configure in SABnzbd web UI to match)";
    };
  };

  config = lib.mkIf cfg.enable {
    services.sabnzbd = {
      enable = true;
      user = homelab.user;
      group = homelab.group;
      settings.misc.port = cfg.port;
    };
  };
}
