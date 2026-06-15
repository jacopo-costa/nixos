{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homelab.services.newt;
  homelab = config.homelab;
in {
  options.homelab.services.newt = {
    enable = lib.mkEnableOption "User space tunnel client for Pangolin";

    newtEnvPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the Newt environment file";
    };
  };
  config = lib.mkIf cfg.enable {
    services.newt = {
      enable = true;
      environmentFile = cfg.newtEnvPath;
    };
  };
}
