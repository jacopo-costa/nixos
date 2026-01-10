{
  config,
  lib,
  pkgs,
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
      ${pkgs.podman}/bin/podman volume exists crowdsec_db || ${pkgs.podman}/bin/podman volume create crowdsec_db
    '';

    system.activationScripts.createCrowdsecConfVol = lib.mkAfter ''
      ${pkgs.podman}/bin/podman volume exists crowdsec_config || ${pkgs.podman}/bin/podman volume create crowdsec_config
    '';

    system.activationScripts.createTraefikNet = lib.mkAfter ''
      ${pkgs.podman}/bin/podman network exists traefik || ${pkgs.podman}/bin/podman network create traefik
    '';

    systemd.tmpfiles.rules = [
      "d /srv/${container} 0755 root root -"
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
