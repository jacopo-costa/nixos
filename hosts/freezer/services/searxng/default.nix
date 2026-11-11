# SearXNG: private meta search engine. Default engines; customize under `settings`.
# $SEARX_SECRET_KEY is filled in from the env file by the module.
{config, ...}: {
  sops = {
    secrets."searxng/secretKey" = {};
    templates.searxngEnv.content = ''
      SEARX_SECRET_KEY=${config.sops.placeholder."searxng/secretKey"}
    '';
  };

  services.searx = {
    enable = true;
    environmentFile = config.sops.templates.searxngEnv.path;
    # Local valkey, like the docker stack
    redisCreateLocally = true;
    settings.server = {
      base_url = "https://search.dimoracosta.it/";
      bind_address = "127.0.0.1";
      port = 8888;
      secret_key = "$SEARX_SECRET_KEY";
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.searxng = {
      rule = "Host(`search.dimoracosta.it`)";
      entryPoints = ["websecure"];
      service = "searxng";
    };
    services.searxng.loadBalancer.servers = [{url = "http://127.0.0.1:8888";}];
  };
}
