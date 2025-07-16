{
  lib,
  config,
  ...
}: let
  cfg = config.desktop;
in {
  options.desktop = {
    enable = lib.mkEnableOption "The desktop services and configuration variables";
    user = lib.mkOption {
      default = "share";
      type = lib.types.str;
      description = ''
        User to run the desktop services as
      '';
    };
    group = lib.mkOption {
      default = "share";
      type = lib.types.str;
      description = ''
        Group to run the desktop services as
      '';
    };
    timeZone = lib.mkOption {
      default = "Europe/Rome";
      type = lib.types.str;
      description = ''
        Time zone to be used for the desktop services
      '';
    };
  };
  imports = [
    ./services
    ./samba
    ./networks
    ./motd
    ./fail2ban-cloudflare
  ];
  config = lib.mkIf cfg.enable {
    users = {
      groups.${cfg.group} = {
        gid = 993;
      };
      users.${cfg.user} = {
        uid = 994;
        isSystemUser = true;
        group = cfg.group;
      };
    };
  };
}
