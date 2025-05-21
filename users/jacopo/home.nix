{
  config,
  pkgs,
  ...
}: {
  home.username = "jacopo";
  home.homeDirectory = "/home/jacopo";
  home.stateVersion = "24.11";

  programs.zsh.enable = true;
  programs.git.enable = true;

  home.packages = with pkgs; [
    htop
  ];
}
