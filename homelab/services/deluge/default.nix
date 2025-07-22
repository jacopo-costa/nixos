{
  config,
  lib,
  pkgs,
  ...
}: let
  service = "deluge";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in {
  options.homelab.services.deluge = {
    enable = lib.mkEnableOption "Deluge torrent client";
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "deluge.${homelab.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Deluge";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Torrent client";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "deluge.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Downloads";
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      openFirewall = true;
      user = homelab.user;
      group = homelab.group;
      web = {
        enable = true;
      };
    };
  };
}
