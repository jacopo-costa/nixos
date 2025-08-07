{
  config,
  lib,
  pkgs,
  ...
}: let
  service = "immich";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in {
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption "Self-hosted photo and video management solution";
    user = lib.mkOption {
      default = config.homelab.user;
      type = lib.types.str;
      description = "User to run Immich as";
    };
    group = lib.mkOption {
      default = config.homelab.group;
      type = lib.types.str;
      description = "Group to run Immich as";
    };
    mediaDir = lib.mkOption {
      type = lib.types.path;
      default = "/tank/immich";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "photos.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 2283;
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = ["d ${cfg.mediaDir} 0775 immich ${homelab.group} - -"];
    users.users.immich.extraGroups = [
      "video"
      "render"
    ];
    services.${service} = {
      group = homelab.group;
      enable = true;
      port = cfg.port;
      mediaLocation = "${cfg.mediaDir}";
    };

    environment.systemPackages = with pkgs; [
      immich-cli
    ];

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://${config.services.immich.host}:${toString cfg.port}
      '';
    };
  };
}
