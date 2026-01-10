{
  config,
  lib,
  ...
}: let
  container = "crowdsec";
  cfg = config.homelab.containers.${container};
  homelab = config.homelab;
in {
  options.homelab.containers.${container} = {
    enable = lib.mkEnableOption "Enable crowdsec security service";
  };
  config = lib.mkIf cfg.enable {
    system.activationScripts.createCrowdsecDBVol = lib.mkAfter ''
      podman volume exists crowdsec_db || podman volume create crowdsec_db
    '';

    system.activationScripts.createCrowdsecConfVol = lib.mkAfter ''
      podman volume exists crowdsec_config || podman volume create crowdsec_config
    '';

    system.activationScripts.createTraefikNet = lib.mkAfter ''
      podman network exists traefik || podman network create traefik
    '';

    systemd.tmpfiles.rules = [
      "d /srv/crowdsec 0755 root root -"
    ];

    virtualisation.oci-containers.containers = {
      crowdsec = {
        image = "crowdsecurity/crowdsec:latest";

        networks = [
          "traefik"
        ];

        environment = {
          COLLECTIONS = "crowdsecurity/traefik crowdsecurity/http-cve crowdsecurity/base-http-scenarios crowdsecurity/linux crowdsecurity/appsec-generic-rules crowdsecurity/appsec-virtual-patching crowdsecurity/appsec-crs";
        };

        volumes = [
          "/srv/crowdsec/acquis.yaml:/etc/crowdsec/acquis.yaml"
          "/srv/crowdsec/appsec.yaml:/etc/crowdsec/acquis.d/appsec.yaml"
          "crowdsec_db:/var/lib/crowdsec/data/"
          "crowdsec_config:/etc/crowdsec/"
          "traefik_logs:/var/log/traefik:ro"
        ];

        autoStart = true;
      };
    };
  };
}
