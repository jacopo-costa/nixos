{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homelab.services.immich;
  homelab = config.homelab;
in {
  options.homelab.services.immich = {
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
      default = "/mnt/tank/immich";
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
    services.immich = {
      enable = true;
      group = homelab.group;
      port = cfg.port;
      mediaLocation = "${cfg.mediaDir}";
      accelerationDevices = ["/dev/dri/renderD128"];
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      extraConfig = ''
        reverse_proxy http://${config.services.immich.host}:${toString cfg.port}
      '';
    };
  };
}
