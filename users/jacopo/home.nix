{
  lib,
  pkgs,
  osConfig,
  ...
}: let
  isDesktop = osConfig.desktop.enable or false;
  homeDir = "/home/jacopo";
in {
  home.username = "jacopo";
  home.homeDirectory = homeDir;
  home.stateVersion = "26.05";

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

    vscode = lib.mkIf isDesktop {
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

    firefox = lib.mkIf isDesktop {
      enable = true;

      languagePacks = [
        "en-US"
        "it"
      ];

      policies = {
        # Updates & Background Services
        AppAutoUpdate = false;
        BackgroundAppUpdate = false;

        # Feature Disabling
        DisableFirefoxAccounts = true;
        DisableFirefoxScreenshots = true;
        DisableFirefoxStudies = true;
        DisableMasterPasswordCreation = true;
        DisablePocket = true;
        DisableSetDesktopBackground = true;
        DisableTelemetry = true;
        GenerativeAI.Enabled = false;
        NoDefaultBookmarks = true;

        # UI and Behavior
        DisplayMenuBar = "never";
        DisplayBookmarksToolbar = "always";
        DontCheckDefaultBrowser = true;
        HardwareAcceleration = true;
        OfferToSaveLogins = false;
        DefaultDownloadDirectory = "${homeDir}/Scaricati";
        SkipTermsOfUse = true;

        # Locale
        RequestedLocales = [
          "en-US"
          "it"
        ];

        # Permissions
        Permissions = {
          Notifications.BlockNewRequests = true;
        };

        ExtensionSettings = let
          moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
        in {
          "*".installation_mode = "blocked";

          "uBlock0@raymondhill.net" = {
            default_area = "navbar";
            install_url = moz "ublock-origin";
            installation_mode = "force_installed";
            private_browsing = true;
          };

          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            default_area = "navbar";
            install_url = moz "bitwarden-password-manager";
            installation_mode = "force_installed";
            private_browsing = false;
          };

          "floccus@handmadeideas.org" = {
            default_area = "menupanel";
            install_url = moz "floccus";
            installation_mode = "force_installed";
            private_browsing = false;
          };

          "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
            default_area = "menupanel";
            install_url = moz "return-youtube-dislikes";
            installation_mode = "force_installed";
            private_browsing = false;
          };

          "sponsorBlocker@ajay.app" = {
            default_area = "menupanel";
            install_url = moz "sponsorblock";
            installation_mode = "force_installed";
            private_browsing = false;
          };
        };
      };

      profiles.default.search = {
        force = true;
        default = "DuckDuckGo";
        privateDefault = "DuckDuckGo";

        engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@np"];
          };

          "Nix Options" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@no"];
          };

          "NixOS Wiki" = {
            urls = [
              {
                template = "https://wiki.nixos.org/w/index.php";
                params = [
                  {
                    name = "search";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@nw"];
          };
        };
      };
    };
  };

  # Desktop-only
  home.packages = lib.mkIf isDesktop (with pkgs; [
    nextcloud-client
    vlc
    jellyfin-media-player
  ]);
}
