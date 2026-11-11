# SparkyFitness: fitness tracker, podman containers (no NixOS module).
# Secret `sparkyfitness/env` = the old stacks/sparkyfitness/.env, unchanged.
# Data: /var/lib/sparkyfitness/{db,backup,uploads}
{config, ...}: let
  podman = "${config.virtualisation.podman.package}/bin/podman";
in {
  sops.secrets."sparkyfitness/env" = {};

  virtualisation.oci-containers.containers = {
    # Container names are the hostnames used in the .env (SPARKY_FITNESS_DB_HOST, SPARKY_FITNESS_SERVER_HOST)
    sparkyfitness-db = {
      image = "postgres:18.3-alpine";
      networks = ["sparkyfitness"];
      # The database already exists: POSTGRES_* variables are only read when creating a new one
      volumes = ["/var/lib/sparkyfitness/db:/var/lib/postgresql"];
    };

    sparkyfitness-server = {
      image = "codewithcj/sparkyfitness_server:latest";
      dependsOn = ["sparkyfitness-db"];
      networks = ["sparkyfitness"];
      environmentFiles = [config.sops.secrets."sparkyfitness/env".path];
      volumes = [
        "/var/lib/sparkyfitness/backup:/app/SparkyFitnessServer/backup"
        "/var/lib/sparkyfitness/uploads:/app/SparkyFitnessServer/uploads"
      ];
    };

    sparkyfitness-frontend = {
      image = "codewithcj/sparkyfitness:latest";
      dependsOn = ["sparkyfitness-server"];
      networks = ["sparkyfitness"];
      environmentFiles = [config.sops.secrets."sparkyfitness/env".path];
      ports = ["127.0.0.1:3004:80"];
    };
  };

  # The three containers talk to each other by name on their own network
  systemd.services.podman-network-sparkyfitness = {
    description = "Create the sparkyfitness podman network";
    requiredBy = ["podman-sparkyfitness-db.service" "podman-sparkyfitness-server.service" "podman-sparkyfitness-frontend.service"];
    before = ["podman-sparkyfitness-db.service" "podman-sparkyfitness-server.service" "podman-sparkyfitness-frontend.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "${podman} network exists sparkyfitness || ${podman} network create sparkyfitness";
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.sparkyfitness = {
      rule = "Host(`fit.dimoracosta.it`)";
      entryPoints = ["websecure"];
      service = "sparkyfitness";
    };
    services.sparkyfitness.loadBalancer.servers = [{url = "http://127.0.0.1:3004";}];
  };
}
