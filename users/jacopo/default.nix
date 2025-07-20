{
  config,
  pkgs,
  ...
}: {
  users = {
    users = {
      jacopo = {
        hashedPassword = "$y$j9T$2pzGVGk1aptVNUU5iTNKL.$BZ7y/F51YmFdzU5ecEsHbTUyuNaIWnq3hNV10bTlIV4";
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
