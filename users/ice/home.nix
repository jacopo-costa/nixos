{
  config,
  pkgs,
  ...
}: {
  home.username = "ice";
  home.homeDirectory = "/home/ice";
  home.stateVersion = "25.05";

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      oh-my-zsh = {
        enable = true;
        theme = "agnoster";
      };

      shellAliases = {
        ll = "ls -lAh --group-directories-first --color=auto";
        gs = "git status";
        ga = "git add .";
      };

      history.size = 10000;
    };
  };

  home.packages = with pkgs; [
    # Utilities
    htop
  ];
}
