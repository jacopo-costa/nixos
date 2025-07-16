{
  config,
  pkgs,
  ...
}: {
  users = {
    users = {
      jacopo = {
        shell = pkgs.zsh;
        uid = 1000;
        isNormalUser = true;
        description = "Jacopo";
        extraGroups = [
          "wheel"
          "users"
          "podman"
        ];
        group = "jacopo";
      };
    };
    groups = {
      jacopo = {
        gid = 1000;
      };
    };
  };
}
