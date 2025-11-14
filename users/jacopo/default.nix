{
  config,
  pkgs,
  ...
}: {
  sops = {
    secrets = {
      "systemPasswords/jacopo".neededForUsers = true;
    };
  };

  users = {
    users = {
      jacopo = {
        hashedPasswordFile = config.sops.secrets."systemPasswords/jacopo".path;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKK85ZK7b5Y/DxQJm66xjxNSznQUyMW2RN6u2CBNCdM5 jacopo@cooler"
        ];
        shell = pkgs.zsh;
        uid = 1000;
        isNormalUser = true;
        description = "Jacopo";
        extraGroups = [
          "wheel"
          "users"
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
