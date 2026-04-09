{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.pocket-id;
  homelab = config.homelab;
in {
  options.homelab.services.pocket-id = {
    enable = lib.mkEnableOption {
      description = "Enable Pocket-ID";
    };
    pocketIdEnvPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the Pocket-ID environment file";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "auth.${homelab.baseDomain}";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 1411;
    };
  };
  config = lib.mkIf cfg.enable {
    services.pocket-id = {
      enable = true;
      settings = {
        APP_URL = cfg.url;
        TRUST_PROXY = true;
      };
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      extraConfig = ''
        import crowdsec_protected
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };

    # Start Pocket-ID only after caddy
    systemd.services.pocket-id = {
      after = ["caddy.service"];
      wants = ["caddy.service"];
    };
  };
}
