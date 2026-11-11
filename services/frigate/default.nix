# Frigate: cameras/NVR. Config is all here (the UI config editor is read-only).
# Data, recordings and clips: /var/lib/frigate. OpenVINO model: /var/lib/frigate/openvino-model (copied once from the container).
# go2rtc runs as its own service and restreams the cancello camera on rtsp://127.0.0.1:8554.
{config, ...}: let
  # The four cameras with the same model/firmware: only the IP changes.
  # {FRIGATE_RTSP_PASSWORD} is filled in by Frigate at startup from the env file.
  camera = ip: {
    enabled = true;
    detect = {
      width = 640;
      height = 360;
    };
    ffmpeg.inputs = [
      {
        path = "rtsp://admin:{FRIGATE_RTSP_PASSWORD}@${ip}:8554/profile1";
        roles = ["detect"];
      }
      {
        path = "rtsp://admin:{FRIGATE_RTSP_PASSWORD}@${ip}:8554/profile0";
        roles = ["record"];
      }
    ];
  };
in {
  sops = {
    secrets = {
      "frigate/rtspPassword" = {};
      "frigate/cancelloPassword" = {};
    };

    templates = {
      frigateEnv.content = ''
        FRIGATE_RTSP_PASSWORD=${config.sops.placeholder."frigate/rtspPassword"}
        FRIGATE_CANCELLO_PASSWORD=${config.sops.placeholder."frigate/cancelloPassword"}
      '';
      go2rtcEnv.content = ''
        CANCELLO_PASSWORD=${config.sops.placeholder."frigate/cancelloPassword"}
      '';
    };
  };

  services.frigate = {
    enable = true;
    hostname = "cam.dimoracosta.it";
    vaapiDriver = "iHD";
    # The build-time check can't fill in {FRIGATE_*} secrets or see the model in /var/lib
    checkConfig = false;

    settings = {
      version = "0.18-0";

      mqtt = {
        enabled = false;
        host = "192.168.30.3";
        port = 1883;
        user = "mqtt-user";
      };

      ffmpeg.hwaccel_args = "preset-vaapi";

      detectors.ov = {
        type = "openvino";
        device = "GPU";
      };

      model = {
        width = 300;
        height = 300;
        input_tensor = "nhwc";
        input_pixel_format = "bgr";
        path = "/var/lib/frigate/openvino-model/ssdlite_mobilenet_v2.xml";
        labelmap_path = "${config.services.frigate.package}/share/frigate/coco_91cl_bkgr.txt";
      };

      detect = {
        enabled = true;
        fps = 5;
      };

      motion = {
        enabled = true;
        threshold = 40;
        contour_area = 100;
        improve_contrast = true;
      };

      record = {
        enabled = true;
        continuous.days = 0;
        motion.days = 3;
      };

      snapshots = {
        enabled = true;
        retain.default = 30;
      };

      audio = {
        enabled = false;
        max_not_heard = 30;
        min_volume = 500;
      };

      cameras = {
        portico = camera "192.168.20.2";
        mutine = camera "192.168.20.3";
        galline = camera "192.168.20.4";
        giardino = camera "192.168.20.5";

        # Different camera: goes through go2rtc (below), PTZ via ONVIF
        cancello = {
          enabled = true;
          detect = {
            width = 640;
            height = 360;
          };
          ffmpeg.inputs = [
            {
              path = "rtsp://127.0.0.1:8554/cancello_2";
              roles = ["detect"];
              input_args = "preset-rtsp-restream";
            }
            {
              path = "rtsp://127.0.0.1:8554/cancello_1";
              roles = ["record"];
              input_args = "preset-rtsp-restream";
            }
          ];
          onvif = {
            host = "192.168.20.6";
            port = 2020;
            user = "admin1";
            password = "{FRIGATE_CANCELLO_PASSWORD}";
          };
        };
      };
    };
  };

  # ${NAME} in the go2rtc config is filled in by go2rtc from its environment
  services.go2rtc = {
    enable = true;
    settings = {
      api.listen = "127.0.0.1:1984";
      rtsp.listen = "127.0.0.1:8554";
      streams = {
        cancello_1 = ["rtsp://admin1:\${CANCELLO_PASSWORD}@192.168.20.6:554/stream1"];
        cancello_2 = ["rtsp://admin1:\${CANCELLO_PASSWORD}@192.168.20.6:554/stream2"];
      };
    };
  };

  systemd.services = {
    frigate.serviceConfig = {
      EnvironmentFile = [config.sops.templates.frigateEnv.path];
      TimeoutStopSec = 30;
    };
    go2rtc.serviceConfig.EnvironmentFile = config.sops.templates.go2rtcEnv.path;
  };

  # The `nginx` backend is defined in ../nginx
  services.traefik.dynamicConfigOptions.http.routers.frigate = {
    rule = "Host(`cam.dimoracosta.it`)";
    entryPoints = ["websecure"];
    service = "nginx";
  };
}
