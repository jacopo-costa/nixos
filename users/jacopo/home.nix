{
  config,
  pkgs,
  ...
}: {
  home.username = "jacopo";
  home.homeDirectory = "/home/jacopo";
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

  programs.git = {
    enable = true;
    userName = "Jacopo Costa";
    userEmail = "costa.jacopo@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  home.packages = with pkgs; [
    htop
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix
        jnoortheen.nix-ide
        kamadorueda.alejandra
      ];
    })
  ];
}
