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
    packages = with pkgs; [
      kdePackages.kate
    ];
  };
}
