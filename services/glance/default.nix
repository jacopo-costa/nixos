# Glance: dashboard, behind the Pocket-ID login (oidc-auth). Translated from stacks/glance/config/glance.yml:
# - the docker-containers widgets became `monitor` widgets (no docker anymore)
# - container hostnames (radarr, sonarr, seerr) became 127.0.0.1
# - Arcane, Grafana, n8n and the Monitor page are gone
# ${NAME} values are filled in by Glance from the env file.
{config, ...}: let
  # A monitored app: `url` is what you click, `check-url` is what Glance checks (direct, skips Traefik)
  site = title: icon: url: checkUrl: {
    inherit title url;
    icon = "sh:${icon}";
    check-url = checkUrl;
  };
in {
  sops = {
    secrets = {
      "glance/radarrApiKey" = {};
      "glance/sonarrApiKey" = {};
      "glance/seerrApiKey" = {};
    };

    templates.glanceEnv.content = ''
      RADARR_API_KEY=${config.sops.placeholder."glance/radarrApiKey"}
      SONARR_API_KEY=${config.sops.placeholder."glance/sonarrApiKey"}
      SEERR_API_KEY=${config.sops.placeholder."glance/seerrApiKey"}
    '';
  };

  services.glance = {
    enable = true;
    environmentFile = config.sops.templates.glanceEnv.path;

    settings = {
      # 8080 is taken by the crowdsec API
      server.port = 8280;

      branding.app-name = "freezer";

      theme = {
        background-color = "0 0 16";
        primary-color = "43 59 81";
        positive-color = "61 66 44";
        negative-color = "6 96 59";
      };

      pages = [
        {
          name = "Home";
          columns = [
            {
              size = "full";
              widgets = [
                {
                  type = "search";
                  search-engine = "https://search.dimoracosta.it/search?q={QUERY}";
                  bangs = [
                    {
                      title = "YouTube";
                      shortcut = "!yt";
                      url = "https://www.youtube.com/results?search_query={QUERY}";
                    }
                  ];
                }
                {
                  type = "bookmarks";
                  groups = [
                    {
                      title = "Admin";
                      links = [
                        {
                          title = "Traefik";
                          url = "http://traefik.freezer.lan";
                          icon = "sh:traefik";
                        }
                        {
                          title = "Pocket ID";
                          url = "https://auth.dimoracosta.it";
                          icon = "sh:pocket-id";
                        }
                      ];
                    }
                    {
                      title = "Cloud & Productivity";
                      links = [
                        {
                          title = "Nextcloud";
                          url = "https://cloud.dimoracosta.it";
                          icon = "sh:nextcloud";
                        }
                        {
                          title = "Immich";
                          url = "https://photos.dimoracosta.it";
                          icon = "sh:immich";
                        }
                        {
                          title = "Vaultwarden";
                          url = "https://vault.dimoracosta.it";
                          icon = "sh:vaultwarden";
                        }
                        {
                          title = "Trek";
                          url = "https://trip.dimoracosta.it";
                          icon = "sh:trek";
                        }
                      ];
                    }
                    {
                      title = "Media";
                      links = [
                        {
                          title = "Jellyfin";
                          url = "https://media.dimoracosta.it";
                          icon = "sh:jellyfin";
                        }
                        {
                          title = "Seerr";
                          url = "https://req.dimoracosta.it";
                          icon = "sh:seerr";
                        }
                        {
                          title = "Komga";
                          url = "https://manga.dimoracosta.it";
                          icon = "sh:komga";
                        }
                        {
                          title = "Calibre";
                          url = "https://books.dimoracosta.it";
                          icon = "sh:calibre";
                        }
                        {
                          title = "Frigate";
                          url = "https://cam.dimoracosta.it";
                          icon = "sh:frigate";
                        }
                      ];
                    }
                  ];
                }
                {
                  type = "server-stats";
                  servers = [
                    {
                      type = "local";
                      name = "freezer";
                    }
                  ];
                }
              ];
            }
            {
              size = "small";
              widgets = [
                {
                  type = "clock";
                  hour-format = "24h";
                }
                {
                  type = "weather";
                  location = "Novara, Italy";
                  hour-format = "24h";
                  units = "metric";
                }
                {type = "to-do";}
                {
                  type = "custom-api";
                  title = "Steam Specials";
                  cache = "12h";
                  url = "https://store.steampowered.com/api/featuredcategories?cc=it";
                  template = ''
                    <ul class="list list-gap-10 collapsible-container" data-collapse-after="5">
                    {{ range .JSON.Array "specials.items" }}
                      <li>
                        <a class="size-h4 color-highlight block text-truncate" href="https://store.steampowered.com/app/{{ .Int "id" }}/">{{ .String "name" }}</a>
                        <ul class="list-horizontal-text">
                          <li>{{ div (.Int "final_price" | toFloat) 100 | printf "€%.2f" }}</li>
                          {{ $discount := .Int "discount_percent" }}
                          <li{{ if ge $discount 40 }} class="color-positive"{{ end }}>{{ $discount }}% off</li>
                        </ul>
                      </li>
                    {{ end }}
                    </ul>
                  '';
                }
              ];
            }
          ];
        }

        {
          name = "Services";
          columns = [
            {
              size = "full";
              widgets = [
                {
                  type = "monitor";
                  title = "Security";
                  cache = "1m";
                  sites = [
                    (site "Traefik" "traefik" "http://traefik.freezer.lan" "http://traefik.freezer.lan")
                    (site "Pocket ID" "pocket-id" "https://auth.dimoracosta.it" "http://127.0.0.1:1411/healthz")
                    (site "Vaultwarden" "vaultwarden" "https://vault.dimoracosta.it" "http://127.0.0.1:8222/alive")
                    (site "Frigate" "frigate" "https://cam.dimoracosta.it" "http://127.0.0.1:5001/api/version")
                  ];
                }
                {
                  type = "monitor";
                  title = "Cloud";
                  cache = "1m";
                  sites = [
                    (site "Nextcloud" "nextcloud" "https://cloud.dimoracosta.it" "https://cloud.dimoracosta.it/status.php")
                    (site "Immich" "immich" "https://photos.dimoracosta.it" "http://127.0.0.1:2283/api/server/ping")
                  ];
                }
                {
                  type = "monitor";
                  title = "Media";
                  cache = "1m";
                  sites = [
                    (site "Jellyfin" "jellyfin" "https://media.dimoracosta.it" "http://127.0.0.1:8096/health")
                    (site "Seerr" "seerr" "https://req.dimoracosta.it" "http://127.0.0.1:5055/api/v1/status")
                    (site "Komga" "komga" "https://manga.dimoracosta.it" "http://127.0.0.1:25600/actuator/health")
                    (site "Calibre" "calibre" "https://books.dimoracosta.it" "http://127.0.0.1:8083/login")
                    (site "Suwayomi" "suwayomi" "http://suwayomi.freezer.lan" "http://127.0.0.1:4567")
                    (site "Sonarr" "sonarr" "http://sonarr.freezer.lan" "http://127.0.0.1:8989/ping")
                    (site "Radarr" "radarr" "http://radarr.freezer.lan" "http://127.0.0.1:7878/ping")
                    (site "Prowlarr" "prowlarr" "http://prowlarr.freezer.lan" "http://127.0.0.1:9696/ping")
                    (site "Bazarr" "bazarr" "http://bazarr.freezer.lan" "http://127.0.0.1:6767")
                    (site "qBittorrent (VPN)" "qbittorrent" "http://qbittorrent.freezer.lan" "http://127.0.0.1:8090")
                    (site "SABnzbd" "sabnzbd" "http://sabnzbd.freezer.lan" "http://127.0.0.1:8085")
                  ];
                }
                {
                  type = "monitor";
                  title = "Utility";
                  cache = "1m";
                  sites = [
                    (site "SearXNG" "searxng" "https://search.dimoracosta.it" "http://127.0.0.1:8888/healthz")
                    (site "Trek" "trek" "https://trip.dimoracosta.it" "http://127.0.0.1:3000/api/health")
                    (site "SparkyFitness" "sparkyfitness" "https://fit.dimoracosta.it" "http://127.0.0.1:3004")
                  ];
                }
              ];
            }
          ];
        }

        {
          name = "Media";
          columns = [
            {
              size = "full";
              widgets = [
                {
                  type = "rss";
                  title = "Recent Movies";
                  cache = "1h";
                  feeds = [
                    {
                      url = "http://127.0.0.1:7878/feed/v3/rss?apikey=\${RADARR_API_KEY}";
                      title = "Radarr";
                    }
                  ];
                }
                {
                  type = "rss";
                  title = "Recent TV Shows";
                  cache = "1h";
                  feeds = [
                    {
                      url = "http://127.0.0.1:8989/feed/v3/rss?apikey=\${SONARR_API_KEY}";
                      title = "Sonarr";
                    }
                  ];
                }
              ];
            }
            {
              size = "small";
              widgets = [
                {
                  type = "custom-api";
                  title = "Pending Requests";
                  cache = "5m";
                  url = "http://127.0.0.1:5055/api/v1/request?filter=pending&take=10";
                  headers.X-Api-Key = "\${SEERR_API_KEY}";
                  template = ''
                    {{ $results := .JSON.Array "results" }}
                    {{ if eq (len $results) 0 }}
                      <p class="color-subdue text-center">No pending requests</p>
                    {{ else }}
                    <ul class="list list-gap-14">
                      {{ range $results }}
                      <li>
                        <a class="size-h4 color-highlight block text-truncate" href="https://req.dimoracosta.it">{{ .String "media.info.title" }}</a>
                        <p class="size-h5 color-subdue">{{ .String "type" }} &bull; {{ .String "requestedBy.displayName" }}</p>
                      </li>
                      {{ end }}
                    </ul>
                    {{ end }}
                  '';
                }
                {
                  type = "bookmarks";
                  groups = [
                    {
                      title = "Media Apps";
                      links = [
                        {
                          title = "Jellyfin";
                          url = "https://media.dimoracosta.it";
                          icon = "sh:jellyfin";
                        }
                        {
                          title = "Immich";
                          url = "https://photos.dimoracosta.it";
                          icon = "sh:immich";
                        }
                        {
                          title = "Komga";
                          url = "https://manga.dimoracosta.it";
                          icon = "sh:komga";
                        }
                        {
                          title = "Calibre";
                          url = "https://books.dimoracosta.it";
                          icon = "sh:calibre";
                        }
                        {
                          title = "Seerr";
                          url = "https://req.dimoracosta.it";
                          icon = "sh:seerr";
                        }
                      ];
                    }
                  ];
                }
              ];
            }
          ];
        }
      ];
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.glance = {
      rule = "Host(`glance.dimoracosta.it`)";
      entryPoints = ["websecure"];
      middlewares = ["oidc-auth@file"];
      service = "glance";
    };
    services.glance.loadBalancer.servers = [{url = "http://127.0.0.1:8280";}];
  };
}
