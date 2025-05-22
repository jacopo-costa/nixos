{config, ...}: {
  # Enable Plasma, SDDM and CUPS services
  services = {
    # Enable X11 with amdgpu
    xserver = {
      enable = true;
    };

    # Enable Plasma and SDDM
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;

    # Enable CUPS to print documents.
    printing.enable = true;
  };
}
