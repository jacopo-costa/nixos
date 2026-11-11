# Trek: trip planner, podman container (no NixOS module).
# Secret `trek/env` = the old stacks/trek/.env, unchanged (APP_URL, ENCRYPTION_KEY, OIDC_*, ADMIN_*...).
# Data: /var/lib/trek/{data,uploads}
{config, ...}: {
  sops.secrets."trek/env" = {};

  virtualisation.oci-containers.containers.trek = {
    image = "mauriceboe/trek:latest";
    environmentFiles = [config.sops.secrets."trek/env".path];
    environment = {
      DEFAULT_LANGUAGE = "it";
      NODE_ENV = "production";
      PORT = "3000";
      TRUST_PROXY = "1";
      OIDC_ADMIN_CLAIM = "groups";
      OIDC_ADMIN_VALUE = "admins";
      OIDC_DISPLAY_NAME = "Pocket ID";
      OIDC_ONLY = "true";
      OIDC_SCOPE = "openid email profile groups";
    };
    ports = ["127.0.0.1:3000:3000"];
    volumes = [
      "/var/lib/trek/data:/app/data"
      "/var/lib/trek/uploads:/app/uploads"
    ];
    # Same hardening as the compose file
    capabilities = {
      ALL = false;
      CHOWN = true;
      SETUID = true;
      SETGID = true;
    };
    extraOptions = [
      "--read-only"
      "--tmpfs=/tmp:noexec,nosuid,size=64m"
    ];
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.trek = {
      rule = "Host(`trip.dimoracosta.it`)";
      entryPoints = ["websecure"];
      service = "trek";
    };
    services.trek.loadBalancer.servers = [{url = "http://127.0.0.1:3000";}];
  };
}
