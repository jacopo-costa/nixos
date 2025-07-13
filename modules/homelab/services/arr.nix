{...}: {
  services = {
    # ARR Stack
    jellyfin = {
      enable = true;
      group = "arr";
      # Ports 8096, 8920, 7359
      openFirewall = true;
    };

    jellyseerr = {
      enable = true;
      # Port 5055
      openFirewall = true;
    };

    deluge = {
      enable = true;
      web = {
        enable = true;
        # Port 8112
        openFirewall = true;
      };
      group = "arr";
    };

    prowlarr = {
      enable = true;
      # Port 9696
      openFirewall = true;
    };

    flaresolverr = {
      enable = true;
      # Port 8191
      openFirewall = true;
    };

    radarr = {
      enable = true;
      # Port 7878
      openFirewall = true;
      group = "arr";
    };

    sonarr = {
      enable = true;
      # Port 8989
      openFirewall = true;
      group = "arr";
    };
  };
}
