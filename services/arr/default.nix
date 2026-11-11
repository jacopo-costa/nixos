# The *arr suite. Media on the pool: /mnt/tank/arr/{media,torrents,usenet}
#
# Sonarr, Radarr, Bazarr and SABnzbd run as `ice` (uid/gid 950), like the docker PUID/PGID,
# so the files they already own on the pool stay writable without a chown.
{
  imports = [
    ./bazarr.nix
    ./flaresolverr.nix
    ./prowlarr.nix
    ./qbittorrent.nix
    ./radarr.nix
    ./sabnzbd.nix
    ./seerr.nix
    ./sonarr.nix
  ];

  # The containers saw the pool as /arr: keep that path so the folders saved in the apps' databases stay valid
  systemd.tmpfiles.rules = ["L+ /arr - - - - /mnt/tank/arr"];
}
