{...}: {
  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        AllowUsers = ["ice"];
      };
    };
  };
}