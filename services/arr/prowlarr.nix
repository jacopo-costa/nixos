# Prowlarr: indexers. Fresh install (nixpkgs is older than the docker one). Data: /var/lib/prowlarr
{
  services.prowlarr.enable = true;

  services.traefik.dynamicConfigOptions.http = {
    routers.prowlarr = {
      rule = "Host(`prowlarr.freezer.lan`)";
      entryPoints = ["weblocal"];
      service = "prowlarr";
    };
    services.prowlarr.loadBalancer.servers = [{url = "http://127.0.0.1:9696";}];
  };
}
