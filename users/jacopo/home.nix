{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}: let
  isDesktop = osConfig.desktop.enable or false;
in {
  home = {
    username = "jacopo";
    homeDirectory = "/home/jacopo";
    stateVersion = "26.05";
  };

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
        gd = "git diff";
        gc = "git commit -m";
        gp = "git push";
        gpl = "git pull";
        ".." = "cd ..";
      };

      sessionVariables = {
        EDITOR = "nano";
        PAGER = "less";
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
        core.editor = "nano";
        color.ui = true;
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
        "it"
        "en-US"
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
        DefaultDownloadDirectory = "${config.home.homeDirectory}/Scaricati";
        SkipTermsOfUse = true;

        # Locale
        RequestedLocales = [
          "it"
          "en-US"
        ];

        # Permissions
        Permissions = {
          Notifications.BlockNewRequests = true;
        };

        ExtensionSettings = let
          moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
        in {
          "*".installation_mode = "blocked";

          "it-IT@dictionaries.addons.mozilla.org" = {
            install_url = "https://addons.mozilla.org/it/firefox/addon/dizionario-italiano/";
            installation_mode = "force_installed";
          };

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

      profiles.default = {
        name = "default";
        isDefault = true;

        settings = {
          # Privacy
          "privacy.globalprivacycontrol.enabled" = true;
          "network.dns.disablePrefetch" = true;
          "network.prefetch-next" = false;
          "browser.contentblocking.category" = "standard";
          "privacy.clearOnShutdown_v2.formdata" = true;
          "privacy.bounceTrackingProtection.hasMigratedUserActivationData" = true;

          # Localization
          "intl.locale.requested" = "it,en-US";
          "intl.regional_prefs.use_os_locales" = true;
          "browser.urlbar.placeholderName" = "SearXNG";
          "browser.search.region" = "IT";

          # AI
          "browser.ai.control.default" = "blocked";
          "browser.ai.control.pdfjsAltText" = "blocked";
          "browser.ai.control.translations" = "blocked";
          "extensions.ml.enabled" = false;
          "browser.ml.linkPreview.enabled" = false;
          "browser.translations.enable" = false;

          # UI & Behavior
          "browser.toolbars.bookmarks.visibility" = "always";
          "sidebar.verticalTabs" = true;
          "sidebar.revamp" = true;
          "browser.tabs.groups.smart.enabled" = false;
          "accessibility.typeaheadfind.flashBar" = 0;
          "full-screen-api.warning.timeout" = 0;

          # Forms & Autofill
          "extensions.formautofill.addresses.enabled" = false;
          "extensions.formautofill.creditCards.enabled" = false;
          "dom.forms.autocomplete.formautofill" = true;

          # New tab
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.system.showWeatherOptIn" = false;
        };

        search = {
          force = true;
          default = "SearXNG";
          privateDefault = "SearXNG";

          engines = {
            "SearXNG" = {
              urls = [
                {
                  template = "https://search.dimoracosta.it/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
                {
                  template = "https://search.dimoracosta.it/autocompleter";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                  type = "application/x-suggestions+json";
                }
              ];
              icon = "https://search.dimoracosta.it/favicon.svg";
              definedAliases = ["@s"];
            };

            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "channel";
                      value = osConfig.system.stateVersion;
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
                      value = osConfig.system.stateVersion;
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
  };

  # Desktop-only
  home.packages = lib.mkIf isDesktop (with pkgs; [
    # Cloud & Sync
    nextcloud-client

    # Media
    vlc
    jellyfin-desktop
  ]);
}
