{config, ...}: {
  sops = {
    # Pocket-ID encryption key
    secrets."pocketIdEnc" = {};

    templates.pocketidEnv = {
      content = ''
        APP_URL = https://pocketid.dimoracosta.it;
        TRUST_PROXY = true;
        ENCRYPTION_KEY_FILE = ${config.sops.placeholder.pocketIdEnc};
      '';
      path = "/var/lib/pocketid/env";
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      pocket-id = {
        image = "ghcr.io/pocket-id/pocket-id:v1";
        workdir = "/var/lib/pocketid";
        environmentFiles = [
          "/var/lib/pocketid/env"
        ];
        volumes = [
          "/var/lib/pocketid/data:/app/data"
        ];
        networks = [
          "pocketid"
        ];
        ports = [
          "127.0.0.1:1411:1411"
        ];
      };
    };
  };
}
