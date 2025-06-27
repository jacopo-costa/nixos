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
    ];
    shell = pkgs.zsh;
  };
}
