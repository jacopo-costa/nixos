# SABnzbd: usenet downloader, no VPN (usenet is already TLS). Data: /var/lib/sabnzbd/sabnzbd.ini
# The ini copied from docker is kept and editable from the UI; the values below always win over it.
{config, ...}: {
  services.sabnzbd = {
    enable = true;
    user = config.homelab.user;
    group = config.homelab.group;
    allowConfigWrite = true;
    settings.misc = {
      host = "127.0.0.1";
      # 8080 is taken by the crowdsec API
      port = 8085;
      # Login always required (requests come through Traefik, never "local")
      inet_exposure = "api+web (auth needed)";
    };
  };

  # Downloads live on the pool: never start without it
  systemd.services.sabnzbd = {
    requires = ["zfs-import-tank.service"];
    after = ["zfs-import-tank.service" "zfs-mount.service"];
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.sabnzbd = {
      rule = "Host(`sabnzbd.freezer.lan`)";
      entryPoints = ["weblocal"];
      service = "sabnzbd";
    };
    services.sabnzbd.loadBalancer.servers = [{url = "http://127.0.0.1:8085";}];
  };
}
