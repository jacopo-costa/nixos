{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Alejandra
    alejandra
    # Multimedia
    spotify
    vlc
    # Spelling
    aspell
    aspellDicts.it
    aspellDicts.en
  ];
}
