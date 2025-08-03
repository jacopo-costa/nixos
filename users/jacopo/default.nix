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
