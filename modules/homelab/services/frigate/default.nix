{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.frigate;
  homelab = config.homelab;
in {
  options.homelab.services.frigate = {
    enable = lib.mkEnableOption "Frigate NVR";
    url = lib.mkOption {
      type = lib.types.str;
      default = "cam.${homelab.baseDomain}";
    };
    storageDir = lib.mkOption {
      type = lib.types.path;
      default = "/mnt/tank/frigate";
      description = "Directory for recordings and snapshots on the ZFS tank";
    };
    vaapiDriver = lib.mkOption {
      type = lib.types.enum ["iHD" "i965" "radeonsi" "nouveau"];
      default = "iHD";
      description = "VA-API driver for hardware transcoding. iHD = Intel Gen8+ (Skylake+), i965 = older Intel";
    };
    environmentFilePath = lib.mkOption {
      type = lib.types.path;
      description = "Path to environment file with Frigate secrets (FRIGATE_MQTT_PASSWORD, FRIGATE_RTSP_PASSWORD, etc.)";
    };
    openRtsp = lib.mkEnableOption "Open RTSP port 8554 in the firewall for local camera streams";
    openWebRtc = lib.mkEnableOption "Open WebRTC port 8555 in the firewall";
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Frigate configuration (cameras, detectors, record, etc.) passed to services.frigate.settings";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.storageDir} 0750 frigate frigate - -"
    ];

    services.frigate = {
      enable = true;
      hostname = cfg.url;
      vaapiDriver = cfg.vaapiDriver;
      # Disable build-time config check since {VARIABLE} placeholders
      # in the config are only resolved at runtime via EnvironmentFile
      checkConfig = false;
      settings = lib.recursiveUpdate {
        ffmpeg.hwaccel_args = "preset-vaapi";
      } cfg.settings;
    };

    # Serve cam.freezer.lan from the same nginx vhost as the external URL
    services.nginx.virtualHosts."${cfg.url}".serverAliases = [
      "cam.${homelab.localDomain}"
    ];

    # Inject runtime secrets (FRIGATE_MQTT_PASSWORD, FRIGATE_RTSP_PASSWORD, etc.)
    systemd.services.frigate.serviceConfig.EnvironmentFile = cfg.environmentFilePath;

    networking.firewall.allowedTCPPorts =
      lib.optionals cfg.openRtsp [8554]
      ++ lib.optionals cfg.openWebRtc [8555];
    networking.firewall.allowedUDPPorts = lib.optionals cfg.openWebRtc [8555];

    systemd.services.frigate = {
      after = ["newt.service"];
      wants = ["newt.service"];
      serviceConfig.TimeoutStopSec = 30;
    };
  };
}
