{config, ...}: {
  environment.etc = {
    "aliases" = {
      text = ''
        root: costa.jacopo@gmail.com
      '';
      mode = "0644";
    };
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
}
