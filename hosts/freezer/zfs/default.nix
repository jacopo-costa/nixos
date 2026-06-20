{
  config,
  pkgs,
  ...
}: {
  services.zfs = {
    autoScrub.enable = true;

    zed.settings = {
      ZED_DEBUG_LOG = "/var/log/zed/debug.log";
      ZED_EMAIL_ADDR = config.email.toAddress;
      ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
      ZED_EMAIL_OPTS = "@ADDRESS@";

      ZED_NOTIFY_INTERVAL_SECS = 3600;
      ZED_NOTIFY_VERBOSE = true;

      ZED_USE_ENCLOSURE_LEDS = true;
      ZED_SCRUB_AFTER_RESILVER = true;
    };
  };

  services.logrotate.settings.zed = {
    files = "/var/log/zed/debug.log";
    frequency = "weekly";
    rotate = 4;
    compress = true;
    missingok = true;
    notifempty = true;
  };
}
