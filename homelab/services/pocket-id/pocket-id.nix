{
  config,
  lib,
  ...
}: let
  service = "pocket-id";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in {
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
    imageUrl = lib.mkOption {
      type = lib.types.str;
      default = "ghcr.io/pocket-id/pocket-id:v1";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${homelab.baseDomain}";
    };
  };

  # TODO: at the next major release (> 25.05) change to service
  config = lib.mkIf cfg.enable {
    sops = {
      # Pocket-ID encryption key
      secrets."pocketIdEnc" = {};

      templates.pocketidEnv = {
        content = ''
          APP_URL=${cfg.url}
          TRUST_PROXY=true
          ENCRYPTION_KEY=${config.sops.placeholder.pocketIdEnc}
        '';
        path = "/var/lib/${service}/env";
      };
    };

    virtualisation.oci-containers = {
      containers = {
        ${service} = {
          image = "${cfg.imageUrl}";
          workdir = "/var/lib/${service}";
          environmentFiles = [
            /var/lib/${service}/env
          ];
          volumes = [
            "/var/lib/${service}/data:/app/data"
          ];
          networks = [
            "${service}"
          ];
          ports = [
            "127.0.0.1:1411:1411"
          ];
        };
      };
    };
  };
}
