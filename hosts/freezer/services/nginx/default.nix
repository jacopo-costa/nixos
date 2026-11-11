# nginx is pulled in by the Nextcloud and Frigate modules, which bring their own vhosts.
# Traefik owns ports 80/443, so every nginx vhost listens only on 127.0.0.1:8081 and
# Traefik forwards to it (nginx picks the right vhost from the Host header).
{
  services.nginx = {
    defaultListenAddresses = ["127.0.0.1"];
    defaultHTTPListenPort = 8081;
  };

  # Backend used by the nextcloud and frigate routers
  services.traefik.dynamicConfigOptions.http.services.nginx.loadBalancer.servers = [
    {url = "http://127.0.0.1:8081";}
  ];
}
