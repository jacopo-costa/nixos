# Radarr: movies. Data: /var/lib/radarr/.config/Radarr
{config, ...}: {
  services.radarr = {
    enable = true;
    user = config.homelab.user;
    group = config.homelab.group;
  };

  # Media lives on the pool: never start without it
  systemd.services.radarr = {
    requires = ["zfs-import-tank.service"];
    after = ["zfs-import-tank.service" "zfs-mount.service"];
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.radarr = {
      rule = "Host(`radarr.freezer.lan`)";
      entryPoints = ["weblocal"];
      service = "radarr";
    };
    services.radarr.loadBalancer.servers = [{url = "http://127.0.0.1:7878";}];
  };
}
