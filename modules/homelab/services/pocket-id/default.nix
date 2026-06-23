{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.pocket-id;
  homelab = config.homelab;
in {
  options.homelab.services.pocket-id = {
    enable = lib.mkEnableOption "Pocket-ID OIDC provider";
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

    systemd.services.create-pocket-id-network = {
      description = "Create pocket-id Docker network";
      after = ["docker.service"];
      requires = ["docker.service"];
      before = ["docker-pocket-id.service"];
      wantedBy = ["docker-pocket-id.service"];
      serviceConfig.Type = "oneshot";
      script = ''
        docker network inspect pocket-id > /dev/null 2>&1 || docker network create pocket-id
      '';
    };

    virtualisation.oci-containers.containers.pocket-id = {
      image = "ghcr.io/pocket-id/pocket-id:v2";
      ports = ["127.0.0.1:${toString cfg.port}:1411"];
      volumes = ["/var/lib/pocket-id:/app/data"];
      environmentFiles = [cfg.pocketIdEnvPath];
      networks = ["pocket-id"];
      extraOptions = [
        "--health-cmd=/app/pocket-id healthcheck"
        "--health-interval=90s"
        "--health-timeout=5s"
        "--health-retries=2"
        "--health-start-period=10s"
      ];
    };

    systemd.services.docker-pocket-id = {
      wants = ["newt.service"];
    };
  };
}
