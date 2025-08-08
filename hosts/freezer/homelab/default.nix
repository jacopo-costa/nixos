{...}: {
  homelab = {
    enable = true;
    timeZone = "Europe/Rome";
    services = {
      containerization = true;
      containerizationType = "docker";
    };
  };
}
