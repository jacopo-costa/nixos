{...}: {
  virtualisation.arion = {
    projects.traefik.settings = {
      project.name = "traefik";

      networks.traefik.name = "traefik";

      docker-compose.volumes.logs = {};

      services.traefik = {
        service = {
          image = "traefik:latest";
          container_name = "traefik";

          networks = ["traefik"];

          ports = [
            "80:80"
            "443:443"
          ];

          environment = {
            CF_DNS_API_TOKEN = "\${CF_DNS_API_TOKEN}"; # Literal to be filled at runtime
          };

          volumes = [
            "/var/run/docker.sock:/var/run/docker.sock:ro"
            "./config/traefik.yaml:/etc/traefik/traefik.yaml:ro"
            "./config/dynamic/:/etc/traefik/dynamic/:ro"
            "./data/certs/:/var/traefik/certs/:rw"
            "logs:/var/log/traefik"
          ];

          restart = "unless-stopped";
        };
      };

      services.catchall = {
        service = {
          image = "nginx:latest";
          container_name = "catchall";

          networks = ["traefik"];

          restart = "unless-stopped";

          volumes = [
            "./catchall:/usr/share/nginx/html:ro"
          ];

          labels = {
            "traefik.enable" = "true";
            "traefik.http.routers.catchall.rule" = "Host(`dimoracosta.it`) || HostRegexp(`.+\\.dimoracosta\\.it`)";
            "traefik.http.routers.catchall.entrypoints" = "websecure";
            "traefik.http.routers.catchall.tls" = "true";
            "traefik.http.routers.catchall.tls.certResolver" = "cloudflare";
            "traefik.http.routers.catchall.priority" = "1";
            "traefik.http.routers.catchall.middlewares" = "crowdsec-bouncer@file,ratelimiter@file";
            "traefik.http.services.catchall.loadbalancer.server.port" = "80";
          };
        };
      };
    };
  };
}
