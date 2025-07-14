{pkgs, ...}: {
  imports = [
    ./pocket-id.nix
    ./arr.nix
    ./vaultwarden.nix
  ];

  # Enable docker
  virtualisation.docker = {
    enable = true;
  };

  environment.systemPackages = [
    pkgs.docker-compose
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
