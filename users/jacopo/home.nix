{
  config,
  lib,
  pkgs,
  osConfig,
  inputs,
  ...
}: let
  isDesktop = osConfig.desktop.enable or false;
  system = pkgs.stdenv.hostPlatform.system;
in {
  home.username = "jacopo";
  home.homeDirectory = "/home/jacopo";
  home.stateVersion = "25.11";

  # Always present
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
      userName = "Jacopo Costa";
      userEmail = "costa.jacopo@gmail.com";
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };
  };

  # Desktop-only
  home.packages = lib.mkIf isDesktop (with pkgs; [
    nextcloud-client
    vlc
    jellyfin-media-player
    inputs.zen-browser.packages.${system}.default
  ]);
}
