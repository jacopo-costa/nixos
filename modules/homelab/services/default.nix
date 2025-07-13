{...}: {
  imports = [
    ./arr.nix
    ./vaultwarden.nix
    ./nextcloud.nix
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
