{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.immich;
  homelab = config.homelab;
in {
  options.homelab.services.immich = {
    enable = lib.mkEnableOption "Self-hosted photo and video management solution";
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
    accelerationDevices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["/dev/dri/renderD128"];
      description = "GPU render node(s) for VA-API hardware transcoding";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = ["d ${cfg.mediaDir} 0775 immich ${homelab.group} - -"];

    users.users.immich.extraGroups = ["video" "render"];

    services.immich = {
      enable = true;
      group = homelab.group;
      port = cfg.port;
      mediaLocation = cfg.mediaDir;
      accelerationDevices = cfg.accelerationDevices;
    };

    systemd.services.immich-server = {
      wants = ["newt.service"];
    };
  };
}
