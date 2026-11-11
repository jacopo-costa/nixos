# One folder per app. Comment out a line to turn that app off.
{
  imports = [
    # Reverse proxy + security
    ./traefik
    ./crowdsec

    # Auth + passwords
    ./pocket-id
    ./vaultwarden

    # Media automation
    ./arr

    # Media
    ./jellyfin
    ./komga
    ./suwayomi

    # Photos + cloud
    # ./immich  # needs NixOS 26.11: 26.05 ships immich 2.x, the database is already 3.x
  ];
}
