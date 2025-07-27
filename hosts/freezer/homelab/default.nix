{config, ...}: let
  hl = config.homelab;
in {
  sops = {
    secrets.cloudflareToken = {};
    secrets.vaultwardenAdminToken = {};

    templates = {
      traefikEnv.content = ''
        CF_DNS_API_TOKEN=${config.sops.placeholder.cloudflareToken}
      '';
      vaultwardenEnv.content = ''
        DOMAIN=https://vault.${hl.baseDomain}
        SIGNUPS_ALLOWED=false
        ADMIN_TOKEN='${config.sops.placeholder.vaultwardenAdminToken}'
        ROCKET_ADDRESS=127.0.0.1
        ROCKET_PORT=8222
        EXTENDED_LOGGING=true
        LOG_LEVEL=warn
        IP_HEADER=X-Real-IP
      '';
    };
  };

  homelab = {
    enable = true;
    timeZone = "Europe/Rome";
    services = {
      enable = true;
      containerizationType = "docker";

      traefik = {
        enable = true;
        traefikEnvPath = config.sops.templates.traefikEnv.path;
      };
    };
  };
}
