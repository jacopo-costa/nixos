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
    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
      daemon.settings = {
        userland-proxy = false;
        ipv6 = false;
      };
    };

    virtualisation.oci-containers = {
      backend = "docker";
    };
  };
}
