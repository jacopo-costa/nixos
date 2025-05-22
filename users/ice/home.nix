{
  config,
  pkgs,
  ...
}: {
  home.username = "ice";
  home.homeDirectory = "/home/ice";
  home.stateVersion = "24.11";

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh.enable = true;
    oh-my-zsh.theme = "agnoster";
    shellAliases = {
      ll = "ls -l";
      gs = "git status";
      ga = "git add .";
    };
  };

  home.packages = with pkgs; [
    htop
  ];
}
