{config, ...}: {
  # Enable Plasma, SDDM and CUPS services
  services = {
    # Enable X11
    xserver = {
      enable = true;
    };

    # Enable Plasma and SDDM
    desktopManager.plasma6.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    # Enable CUPS to print documents.
    printing.enable = true;
  };
}
