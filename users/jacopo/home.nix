{
  lib,
  pkgs,
  osConfig,
  ...
}: let
  isDesktop = osConfig.desktop.enable or false;
in {
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

      history.size = 5000;
    };

    git = {
      enable = true;
      settings = {
        user.name = "Jacopo Costa";
        user.email = "costa.jacopo@gmail.com";
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };

    vscode = {
      enable = true;
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          bbenoist.nix
          jnoortheen.nix-ide
          kamadorueda.alejandra
        ];
        userSettings = {
          "editor.formatOnSave" = true;
          "[nix]"."editor.defaultFormatter" = "kamadorueda.alejandra";
        };
        keybindings = [];
      };
    };
  };

  # Desktop-only
  home.packages = lib.mkIf isDesktop (with pkgs; [
    nextcloud-client
    vlc
    jellyfin-media-player
    ungoogled-chromium
  ]);
}