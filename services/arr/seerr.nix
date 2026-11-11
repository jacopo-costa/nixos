# Seerr: media requests. Data: /var/lib/seerr
{
  services.seerr = {
    enable = true;
    port = 5055;
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.seerr = {
      rule = "Host(`req.dimoracosta.it`)";
      entryPoints = ["websecure"];
      service = "seerr";
    };
    services.seerr.loadBalancer.servers = [{url = "http://127.0.0.1:5055";}];
  };
}
