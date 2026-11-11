# Calibre-Web-Automated: ebook library, podman container (no NixOS module).
# Secret `calibre-web-automated/env` = the old stacks/calibre-web-automated/.env, unchanged (HARDCOVER_TOKEN).
# Data: /var/lib/calibre-web-automated/{config,library,ingest}. Drop books in ingest/ to import them.
{config, ...}: {
  sops.secrets."calibre-web-automated/env" = {};

  virtualisation.oci-containers.containers.calibre-web-automated = {
    image = "crocodilestick/calibre-web-automated:latest";
    environmentFiles = [config.sops.secrets."calibre-web-automated/env".path];
    environment = {
      # Same owner as in docker (jacopo)
      PUID = "1000";
      PGID = "1000";
      TZ = config.time.timeZone;
      NETWORK_SHARE_MODE = "false";
      CWA_PORT_OVERRIDE = "8083";
    };
    ports = ["127.0.0.1:8083:8083"];
    volumes = [
      "/var/lib/calibre-web-automated/config:/config"
      "/var/lib/calibre-web-automated/library:/calibre-library"
      "/var/lib/calibre-web-automated/ingest:/cwa-book-ingest"
    ];
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.cwa = {
      rule = "Host(`books.dimoracosta.it`)";
      entryPoints = ["websecure"];
      service = "cwa";
    };
    services.cwa.loadBalancer.servers = [{url = "http://127.0.0.1:8083";}];
  };
}
