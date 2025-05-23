{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Multimedia
    spotify
    vlc
    # Spelling
    aspell
    aspellDicts.it
    aspellDicts.en
  ];
}
