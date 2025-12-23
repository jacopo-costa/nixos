{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.containers;
in {
  imports = [];

  # Options
  options.homelab.containers = {
    enable = lib.mkEnableOption "Enable containers for the homelab";
  };

  config = lib.mkIf cfg.enable {
    # Setup containerization
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [
          "--filter=until=24h"
          "--filter=label!=important"
        ];
      };
      defaultNetwork.settings.dns_enabled = true;
    };

    virtualisation.oci-containers = {
      backend = "podman";
    };
  };
}
