# Sonarr: TV shows. Data: /var/lib/sonarr/.config/NzbDrone
{config, ...}: {
  services.sonarr = {
    enable = true;
    user = config.homelab.user;
    group = config.homelab.group;
  };

  # Media lives on the pool: never start without it
  systemd.services.sonarr = {
    requires = ["zfs-import-tank.service"];
    after = ["zfs-import-tank.service" "zfs-mount.service"];
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.sonarr = {
      rule = "Host(`sonarr.freezer.lan`)";
      entryPoints = ["weblocal"];
      service = "sonarr";
    };
    services.sonarr.loadBalancer.servers = [{url = "http://127.0.0.1:8989";}];
  };
}
