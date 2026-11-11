# Suwayomi: manga downloader/reader. Fresh install + restore of the backup made in the docker one.
# Data: /var/lib/suwayomi-server. Downloads: /opt/suwayomi (also read by Komga).
# server.conf is rewritten from these settings at every start: change settings here, not in the UI.
{
  services.suwayomi-server = {
    enable = true;
    settings.server = {
      ip = "127.0.0.1";
      port = 4567;
      downloadsPath = "/opt/suwayomi";
      flareSolverrEnabled = true;
      flareSolverrUrl = "http://127.0.0.1:8191";
    };
  };

  # Group-readable so Komga (in the suwayomi group) can read the downloads
  systemd.tmpfiles.rules = ["d /opt/suwayomi 0750 suwayomi suwayomi -"];

  services.traefik.dynamicConfigOptions.http = {
    routers.suwayomi = {
      rule = "Host(`suwayomi.freezer.lan`)";
      entryPoints = ["weblocal"];
      service = "suwayomi";
    };
    services.suwayomi.loadBalancer.servers = [{url = "http://127.0.0.1:4567";}];
  };
}
