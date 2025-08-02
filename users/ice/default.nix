{
  config,
  pkgs,
  ...
}: {
  sops = {
    secrets = {
      "systemPasswords/ice" = {};
    };
  };

  users = {
    users = {
      ice = {
        hashedPassword = "$y$j9T$YEaZZClBUY0tZWpUrZ8AM1$LUqJ.8KDEte0S8zGK.ICXUmLe7NEErdQn4qZmEMFpxA";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKK85ZK7b5Y/DxQJm66xjxNSznQUyMW2RN6u2CBNCdM5 jacopo@cooler"
        ];
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
