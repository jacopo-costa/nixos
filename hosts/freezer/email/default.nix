{config, ...}: {
  sops = {
    secrets = {
      "smtp.password" = {};
    };
  };

  email = {
    enable = true;
    fromAddress = "dimoracosta.system@gmail.com";
    toAddress = "costa.jacopo@gmail.com";
    smtpServer = "smtp.gmail.com";
    smtpPort = 587;
    smtpUsername = "dimoracosta.system@gmail.com";
    smtpPasswordPath = config.sops.secrets."smtp.password".path;
  };
}
