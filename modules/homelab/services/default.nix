{...}: {
  imports = [
    ./arr.nix
    ./vaultwarden.nix
  ];

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
