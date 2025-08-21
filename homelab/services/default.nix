{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homelab.services;
in {
  imports = [];

  # Options
  options.homelab.services = {
    enable = lib.mkEnableOption "Enable services for the homelab";
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
