# Immich: photos. Photos on the pool: /mnt/tank/immich. Database: local postgres (created by the module).
# Settings stay in the admin UI (stored in the database), like in docker.
# On first start Immich rewrites the file paths in its database from /data (the container path) to /mnt/tank/immich by itself.
{
  services.immich = {
    enable = true;
    host = "127.0.0.1";
    port = 2283;
    mediaLocation = "/mnt/tank/immich";
    # GPU for VA-API transcoding
    accelerationDevices = ["/dev/dri/renderD128"];
  };

  users.users.immich.extraGroups = ["render" "video"];

  # Photos live on the pool: never start without it
  systemd.services.immich-server = {
    requires = ["zfs-import-tank.service"];
    after = ["zfs-import-tank.service" "zfs-mount.service"];
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.immich = {
      rule = "Host(`photos.dimoracosta.it`)";
      entryPoints = ["websecure"];
      service = "immich";
    };
    services.immich.loadBalancer.servers = [{url = "http://127.0.0.1:2283";}];
  };
}
