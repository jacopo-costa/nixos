{
  config,
  pkgs,
  ...
}: {
  users.users.ice = {
    isNormalUser = true;
    description = "ice";
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
  };
}
