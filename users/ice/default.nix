{
  config,
  pkgs,
  ...
}: {
  # sops = {
  #   secrets = {
  #     "systemPasswords/ice" = {};
  #   };
  # };

  users = {
    users = {
      ice = {
        # hashedPasswordFile = config.sops.secrets."systemPasswords/ice".path;
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
