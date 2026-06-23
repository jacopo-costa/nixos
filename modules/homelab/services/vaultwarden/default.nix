{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.vaultwarden;
  homelab = config.homelab;
in {
  options.homelab.services.vaultwarden = {
    enable = lib.mkEnableOption "Enable Vaultwarden";
    vaultwardenEnvPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the Vaultwarden environment file";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "vault.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8222;
    };
  };

  config = lib.mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      environmentFile = cfg.vaultwardenEnvPath;
    };

    systemd.services.vaultwarden = {
      wants = ["newt.service"];
    };
  };
}
