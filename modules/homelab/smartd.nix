{pkgs, ...}: {
  # Enable smartd
  services.smartd = {
    enable = true;
    autodetect = true;

    defaults.monitored = "-a -o on -s (S/../.././10|L/../../7/11)";

    notifications = {
      test = true;
      mail = {
        enable = true;
        sender = "dimoracosta.system@gmail.com";
        recipient = "dimoracosta.system@gmail.com";
      };
    };
  };
}
