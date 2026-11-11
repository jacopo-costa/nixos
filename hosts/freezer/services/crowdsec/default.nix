# CrowdSec: reads the Traefik access log and answers the Traefik bouncer plugin.
#   LAPI   127.0.0.1:8080 (IP decisions)
#   AppSec 127.0.0.1:7422 (request inspection / WAF)
# The bouncer key is registered once by hand, see MIGRATION.md.
{
  services.crowdsec = {
    enable = true;
    autoUpdateService = true;

    hub.collections = [
      "crowdsecurity/traefik"
      "crowdsecurity/http-cve"
      "crowdsecurity/base-http-scenarios"
      "crowdsecurity/linux"
      "crowdsecurity/appsec-generic-rules"
      "crowdsecurity/appsec-virtual-patching"
      "crowdsecurity/appsec-crs"
    ];

    localConfig.acquisitions = [
      {
        source = "file";
        # Only the live file: logrotate leaves access.log.1/.gz next to it
        filenames = ["/var/log/traefik/access.log"];
        labels.type = "traefik";
      }
      {
        source = "appsec";
        name = "myAppSecComponent";
        listen_addr = "127.0.0.1:7422";
        appsec_config = "crowdsecurity/appsec-default";
        labels.type = "appsec";
      }
    ];

    settings = {
      # Local API, used by the Traefik bouncer
      general.api.server.enable = true;
      # Both files are created on first start
      lapi.credentialsFile = "/var/lib/crowdsec/state/lapi-credentials.yaml";
      # Central API: community blocklists, like the docker image did
      capi.credentialsFile = "/var/lib/crowdsec/state/capi-credentials.yaml";
    };
  };

  # Read /var/log/traefik
  users.users.crowdsec.extraGroups = ["traefik"];
}
