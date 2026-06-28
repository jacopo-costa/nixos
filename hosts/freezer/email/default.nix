{config, ...}: {
  sops = {
    secrets = {
      "smtp/user" = {};
      "smtp/password" = {};
    };
  };

  email = {
    enable = true;
    fromAddress = config.sops.secrets."smtp/user".path;
    toAddress = "costa.jacopo@gmail.com";
    smtpServer = "smtp.gmail.com";
    smtpPort = 587;
    smtpUsername = config.sops.secrets."smtp/user".path;
    smtpPasswordPath = config.sops.secrets."smtp/password".path;
  };
}
