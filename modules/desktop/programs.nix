{
  config,
  pkgs,
  ...
}: {
  # Programs
  programs = {
    zsh.enable = true;

    firefox = {
      enable = true;
      preferences = {
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };
    };

    steam = {
      package = pkgs.steam.override {
        extraPkgs = p: [
          p.kdePackages.breeze
        ];
      };
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };
}
