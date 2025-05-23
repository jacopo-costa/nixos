{
  config,
  pkgs,
  ...
}: {
  home.username = "jacopo";
  home.homeDirectory = "/home/jacopo";
  home.stateVersion = "24.11";

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
      userName = "Jacopo Costa";
      userEmail = "costa.jacopo@gmail.com";
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };
  };

  home.packages = with pkgs; [
    # Utilities
    htop
    # Alejandra
    alejandra
    # VSCode
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix
        jnoortheen.nix-ide
        kamadorueda.alejandra
      ];
    })
  ];
}
