{
  config,
  pkgs,
  ...
}: {
  # Programs
  programs = {
    # Shell
    zsh.enable = true;

    # Firefox
    firefox = {
      enable = true;
      preferences = {
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };
    };
  };
}
