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
  ];
}
