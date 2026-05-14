{
  config,
  lib,
  ...
}: let
  service = "paperless";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in {
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    mediaDir = lib.mkOption {
      type = lib.types.str;
      default = "/tank/paperless/documents";
    };
    consumptionDir = lib.mkOption {
      type = lib.types.str;
      default = "/tank/paperless/import";
    };
    paperlessAdminPassPath = lib.mkOption {
      type = lib.types.path;
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "doc.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 28981;
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      passwordFile = cfg.paperlessAdminPassPath;
      user = homelab.user;
      mediaDir = cfg.mediaDir;
      consumptionDir = cfg.consumptionDir;
      consumptionDirIsPublic = true;
      port = cfg.port;
      settings = {
        PAPERLESS_URL = "https://${cfg.url}";
        PAPERLESS_CONSUMER_IGNORE_PATTERN = [
          ".DS_STORE/*"
          "desktop.ini"
        ];
        PAPERLESS_OCR_LANGUAGE = "ita+eng";
        PAPERLESS_OCR_USER_ARGS = {
          optimize = 1;
          pdfa_image_compression = "lossless";
        };
      };
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
