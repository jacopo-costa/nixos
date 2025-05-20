{
  config,
  pkgs,
  ...
}: {
  home.username = "jacopo";
  home.homeDirectory = "/home/jacopo";

  programs.zsh.enable = true;
  programs.git.enable = true;

  home.packages = with pkgs; [
    steam
    openrgb
    discord
    lutris
  ];

  home.stateVersion = "24.11";
}
