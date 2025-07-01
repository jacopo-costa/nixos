{config, ...}: {

  services = {

    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        AllowUsers = ["ice"];
      };
    };

    vaultwarden = {
      enable = true;
      config = {
        DOMAIN = "https://vault.dimoracosta.it";
        SIGNUPS_ALLOWED = false;

        ADMIN_TOKEN=config.secrets.adminToken;

        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;

        ROCKET_LOG = "critical";

        SMTP_HOST = "smtp.gmail.com";
        SMTP_SECURITY=starttls
        SMTP_PORT = 587;

        SMTP_USERNAME="dimoracosta.system@gmail.com";
        SMTP_PASSWORD=config.secrets.smtpPassword;

        SMTP_FROM = "dimoracosta.system@gmail.com";
        SMTP_FROM_NAME = "Vaultwarden DimoraCosta";
      };

    };
  };
}