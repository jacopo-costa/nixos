{
  config,
  pkgs,
  ...
}: {
  home.username = "ice";
  home.homeDirectory = "/home/ice";

  programs.zsh.enable = true;
  programs.git.enable = true;

  home.packages = with pkgs; [
  ];

  home.stateVersion = "24.11";
}
