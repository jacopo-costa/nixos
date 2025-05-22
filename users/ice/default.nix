{
  config,
  pkgs,
  ...
}: {
  users.users.ice = {
    isNormalUser = true;
    description = "ice";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };
}
