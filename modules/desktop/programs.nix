{
  config,
  pkgs,
  ...
}: {
  # Programs
  programs = {
    # Firefox
    firefox = {
      enable = true;
      preferences = {
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };
    };
  };
}
