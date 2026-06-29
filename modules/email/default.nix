{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.email;
in {
  options.email = {
    enable = lib.mkEnableOption "Email sending functionality";
    fromAddress = lib.mkOption {
      description = "The 'from' address";
      type = lib.types.str;
      default = "dimoracosta.system@gmail.com";
    };
    toAddress = lib.mkOption {
      description = "The 'to' address";
      type = lib.types.str;
      default = "costa.jacopo@gmail.com";
    };
    smtpServer = lib.mkOption {
      description = "The SMTP server address";
      type = lib.types.str;
      default = "smtp.gmail.com";
    };
    smtpPort = lib.mkOption {
      description = "The SMTP server port";
      type = lib.types.int;
      default = 587;
    };
    smtpUsername = lib.mkOption {
      description = "The SMTP username";
      type = lib.types.str;
      default = "dimoracosta.system@gmail.com";
    };
    smtpPasswordPath = lib.mkOption {
      description = "Path to the secret containing SMTP password";
      type = lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.msmtp = {
      enable = true;
      setSendmail = true;
      accounts.default = {
        auth = true;
        host = cfg.smtpServer;
        port = cfg.smtpPort;
        from = cfg.fromAddress;
        user = cfg.smtpUsername;
        tls = true;
        passwordeval = "${pkgs.coreutils}/bin/cat ${cfg.smtpPasswordPath}";
      };
    };
  };
}
