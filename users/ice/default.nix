{
  config,
  pkgs,
  ...
}: {
  users = {
    users = {
      ice = {
        hashedPassword = "$y$j9T$QGK7BBYrIrQoNBLIrPn2W/$./SFj0WhSTuWA6U57wkW3bYjmIJTjj5BhBAcrLvBTQ1";
        shell = pkgs.zsh;
        uid = 1000;
        isNormalUser = true;
        description = "ICE";
        extraGroups = [
          "wheel"
          "users"
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
