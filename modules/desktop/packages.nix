{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # Multimedia
    spotify
    vlc
    # Spelling
    aspell
    aspellDicts.it
    aspellDicts.en
    # KDE Utilities
    kdePackages.kcalc
    kdePackages.sddm-kcm
    kdePackages.partitionmanager
  ];
}
