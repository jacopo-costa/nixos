{...}: {
  imports = [
    ./arr.nix
    ./vaultwarden.nix
  ];

  # Enable docker
  virtualisation.docker = {
    enable = true;
  };

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
