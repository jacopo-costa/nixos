# Jellyfin: media server. Data: /var/lib/jellyfin, cache: /var/cache/jellyfin
# Library paths saved as /arr/media/... keep working through the /arr link (see ../arr).
# Hardware transcoding (VA-API) stays configured in the UI, as before.
{config, ...}: {
  services.jellyfin.enable = true;

  # GPU for transcoding + read the media owned by `ice`
  users.users.jellyfin.extraGroups = ["render" "video" config.homelab.group];

  systemd.services.jellyfin = {
    environment.JELLYFIN_PublishedServerUrl = "https://media.dimoracosta.it";
    # Media lives on the pool: never start without it
    requires = ["zfs-import-tank.service"];
    after = ["zfs-import-tank.service" "zfs-mount.service"];
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.jellyfin = {
      rule = "Host(`media.dimoracosta.it`)";
      entryPoints = ["websecure"];
      service = "jellyfin";
    };
    services.jellyfin.loadBalancer.servers = [{url = "http://127.0.0.1:8096";}];
  };
}
