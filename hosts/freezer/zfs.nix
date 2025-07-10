{
  config,
  pkgs,
  ...
}: {
  boot = {
    supportedFilesystems = ["zfs"];
    zfs.extraPools = ["tank"];
  };

  programs.msmtp = {
    enable = true;
    setSendmail = true;
    defaults = {
      auth = "on";
      tls = "on";
      tls_starttls = "on";
      host = "smtp.gmail.com";
      port = 587;
      aliases = "/etc/aliases";
    };
    accounts = {
      default = {
        user = "dimoracosta.system@gmail.com";
        from = "dimoracosta.system@gmail.com";
        passwordeval = "cat ${config.sops.secrets.smtpPassword.path}";
      };
    };
  };

  services.zfs.zed.settings = {
    ZED_DEBUG_LOG = "/tmp/zed.debug.log";
    ZED_EMAIL_ADDR = ["root"];
    ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
    ZED_EMAIL_OPTS = "@ADDRESS@";

    ZED_NOTIFY_INTERVAL_SECS = 3600;
    ZED_NOTIFY_VERBOSE = true;

    ZED_USE_ENCLOSURE_LEDS = true;
    ZED_SCRUB_AFTER_RESILVER = true;
  };
}
