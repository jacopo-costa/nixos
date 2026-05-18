{
  config,
  pkgs,
  ...
}: {
  home.username = "jacopo";
  home.homeDirectory = "/home/jacopo";
  home.stateVersion = "25.11";

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

    git = {
      enable = true;
      settings = {
        user = {
          name = "Jacopo Costa";
          email = "costa.jacopo@gmail.com";
        };
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };
  };
}
