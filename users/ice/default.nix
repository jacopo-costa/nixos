{
  config,
  pkgs,
  ...
}: {
  users.users.jacopo = {
    isNormalUser = true;
    description = "Jacopo";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };
}
