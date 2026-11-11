# Bazarr: subtitles. Data: /var/lib/bazarr
{config, ...}: {
  services.bazarr = {
    enable = true;
    user = config.homelab.user;
    group = config.homelab.group;
    listenPort = 6767;
  };

  # Media lives on the pool: never start without it
  systemd.services.bazarr = {
    requires = ["zfs-import-tank.service"];
    after = ["zfs-import-tank.service" "zfs-mount.service"];
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.bazarr = {
      rule = "Host(`bazarr.freezer.lan`)";
      entryPoints = ["weblocal"];
      service = "bazarr";
    };
    services.bazarr.loadBalancer.servers = [{url = "http://127.0.0.1:6767";}];
  };
}
