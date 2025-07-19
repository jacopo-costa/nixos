{
  config,
  pkgs,
  ...
}: {
  users = {
    users = {
      ice = {
        shell = pkgs.zsh;
        uid = 1000;
        isNormalUser = true;
        description = "ICE";
        extraGroups = [
          "wheel"
          "users"
          "podman"
        ];
        group = "ice";
      };
    };
    groups = {
      ice = {
        gid = 1000;
      };
    };
  };
}
