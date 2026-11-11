# Docker → NixOS migration (one-time runbook)

Plain commands, run as root on freezer, top to bottom. Docker volumes are **copied, never moved**:
until step 7 you can go back with `nixos-rebuild switch --rollback` + `docker compose up -d`
(then `docker exec -u www-data nextcloud php occ maintenance:mode --off`).

## 0. Before the evening

- [ ] Flake bumped to `nixos-26.11`, and `./immich` uncommented in `services/default.nix`.
- [ ] Versions checked again: nixpkgs must be **equal or newer** than the running containers
      (`docker ps` versions vs `nix eval .#nixosConfigurations.freezer.pkgs.<app>.version`).
      Anything older: keep it as a podman container for now.
- [ ] Every secret below exists in `hosts/_common/secrets/secrets.yaml` (`sops hosts/_common/secrets/secrets.yaml`).
      A missing key makes the whole switch fail.
- [ ] `nixos-rebuild build --flake .#freezer` works.

### Secrets to add

| Key | Value |
|---|---|
| `traefik/cfDnsApiToken` | `CF_DNS_API_TOKEN` from `stacks/traefik/.env` |
| `traefik/oidcSessionSecret` | `OIDC_SESSION_SECRET` from `stacks/traefik/.env` |
| `traefik/oidcClientId`, `traefik/oidcClientSecret` | `OIDC_CLIENT_ID` / `OIDC_CLIENT_SECRET` from `stacks/traefik/.env` |
| `crowdsec/traefikBouncerKey` | new: `openssl rand -hex 32` |
| `pocket-id/encryptionKey`, `pocket-id/maxmindLicenseKey` | `ENCRYPTION_KEY` / `MAXMIND_LICENSE_KEY` from `stacks/pocket-id/.env` |
| `vaultwarden/adminToken` | `ADMIN_TOKEN` from `stacks/vaultwarden/.env` |
| `gluetun/wireguardPrivateKey`, `gluetun/wireguardAddresses` | from `stacks/arr/.env` |
| `komga/oidcClientId`, `komga/oidcClientSecret` | `POCKETID_CLIENTID` / `POCKETID_SECRET` from `stacks/komga/.env` |
| `frigate/rtspPassword` | password of the 4 `admin` cameras |
| `frigate/cancelloPassword` | password of `admin1` on cancello (stream + ONVIF) |
| `glance/radarrApiKey`, `glance/sonarrApiKey`, `glance/seerrApiKey` | from `stacks/glance/.env` |
| `searxng/secretKey` | new: `openssl rand -hex 32` |
| `sparkyfitness/env` | the whole `stacks/sparkyfitness/.env`, as a multi-line value (`key: \|`) |
| `trek/env` | the whole `stacks/trek/.env` |
| `calibre-web-automated/env` | the whole `stacks/calibre-web-automated/.env` |

`smtp/password` is already there.

## 1. Exports (docker still running)

```bash
mkdir -p /root/migration && cd /root/migration

# Nextcloud: freeze it, dump the database
docker exec -u www-data nextcloud php occ maintenance:mode --on
docker exec nextcloud_mariadb sh -c 'mariadb-dump --single-transaction -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' > nextcloud.sql
grep datadirectory /var/lib/docker/volumes/nextcloud/_data/config/config.php   # expect /var/www/html/data

# Immich: dump the database (pgvecto.rs `vectors` must not be in use: check with \dx)
docker exec immich_postgres sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\dx"'
docker exec immich_postgres sh -c 'pg_dump -Fc --no-owner -U "$POSTGRES_USER" "$POSTGRES_DB"' > immich.dump

# Frigate: the OpenVINO model is not in the nixpkgs package
docker cp frigate:/openvino-model ./openvino-model
```

Suwayomi: in the UI, Settings → Backup → create a backup and download the `.tachibk` file.
Also note your extension repositories (Settings → Browse): they go into `services/suwayomi` (`settings.server.extensionRepos`).

## 2. Stop docker

```bash
for c in /srv/stacks/*/compose.yaml; do docker compose -f "$c" stop; done
systemctl stop docker.socket docker
```

## 3. Copy the data into place (before the switch, so no app starts empty)

```bash
V=/var/lib/docker/volumes
cpv() { mkdir -p "$2" && cp -a "$V/$1/_data/." "$2/"; }

cpv pocket-id_data       /var/lib/pocket-id
cpv vaultwarden_data     /var/lib/vaultwarden
cpv sonarr_config        /var/lib/sonarr/.config/NzbDrone
cpv radarr_config        /var/lib/radarr/.config/Radarr
cpv bazarr_config        /var/lib/bazarr
cpv sabnzbd_config       /var/lib/sabnzbd
cpv qbittorrent_config   /var/lib/qbittorrent
mkdir -p -m 0700 /var/lib/private
cpv seerr_config         /var/lib/private/seerr
cpv jellyfin_config      /var/lib/jellyfin
cpv komga_config         /var/lib/komga
cpv komga_data           /var/lib/komga/data
cpv sparkyfitness_db     /var/lib/sparkyfitness/db
cpv sparkyfitness_backup /var/lib/sparkyfitness/backup
cpv sparkyfitness_upload /var/lib/sparkyfitness/uploads
cpv trek_data            /var/lib/trek/data
cpv trek_uploads         /var/lib/trek/uploads
cpv cwa_config           /var/lib/calibre-web-automated/config
cpv cwa_library          /var/lib/calibre-web-automated/library
cp -a /srv/stacks/calibre-web-automated/ingest /var/lib/calibre-web-automated/ingest

# Nextcloud: with config.php in place the module does NOT run a fresh install
mkdir -p /var/lib/nextcloud/config /var/lib/nextcloud/store-apps
cp -a $V/nextcloud/_data/config/config.php /var/lib/nextcloud/config/
cp -a $V/nextcloud/_data/custom_apps/. /var/lib/nextcloud/store-apps/

mkdir -p /var/lib/frigate && cp -a /root/migration/openvino-model /var/lib/frigate/
# Keeps the current certificate (no new request to Let's Encrypt)
mkdir -p /var/lib/traefik && cp /srv/stacks/traefik/data/certs/cloudflare-acme.json /var/lib/traefik/acme.json
```

Not copied, on purpose: prowlarr (fresh), suwayomi (fresh + backup), frigate database (fresh: old
recordings and events stay in the `frigate_storage` volume), crowdsec, searxng, glance, gluetun.

## 4. Switch

```bash
nixos-rebuild switch --flake .#freezer
```

Some apps fail to start here (wrong file owners, empty databases). That's expected, fixed below.

## 5. Owners, databases, restart

```bash
chown -R pocket-id:pocket-id /var/lib/pocket-id
chown -R vaultwarden:vaultwarden /var/lib/vaultwarden
chown -R ice:ice /var/lib/sonarr /var/lib/radarr /var/lib/bazarr /var/lib/sabnzbd /var/lib/qbittorrent
chown -R jellyfin:jellyfin /var/lib/jellyfin
chown -R komga:komga /var/lib/komga
chown -R suwayomi:suwayomi /opt/suwayomi
chown -R frigate:frigate /var/lib/frigate
chown traefik:traefik /var/lib/traefik/acme.json && chmod 600 /var/lib/traefik/acme.json
chown -R nextcloud:nextcloud /var/lib/nextcloud /mnt/tank/nextcloud
chown -R immich:immich /mnt/tank/immich
# seerr, sparkyfitness, trek, cwa: nothing to do (systemd / cp -a keep the right owners)

# Nextcloud database
mysql nextcloud < /root/migration/nextcloud.sql
mysql nextcloud -e "UPDATE oc_storages SET id='local::/mnt/tank/nextcloud/' WHERE id='local::/var/www/html/data/';"
systemctl restart nextcloud-setup phpfpm-nextcloud
nextcloud-occ config:system:delete dbpassword
nextcloud-occ maintenance:mode --off

# Immich database (restored into an empty one; on first start Immich moves the paths /data -> /mnt/tank/immich)
systemctl stop immich-server immich-machine-learning
sudo -u postgres dropdb immich
sudo -u postgres createdb -O immich immich
sudo -u postgres pg_restore --no-owner --role=immich -d immich /root/migration/immich.dump
systemctl start immich-server immich-machine-learning
journalctl -u immich-server | grep -i "media location"

# CrowdSec: let the Traefik plugin in with the key from sops
cscli bouncers add traefik-bouncer --key "$(cat /run/secrets/crowdsec/traefikBouncerKey)"

# Everything else
systemctl restart pocket-id vaultwarden sonarr radarr bazarr sabnzbd seerr jellyfin komga suwayomi-server frigate traefik
systemctl --failed
```

## 6. In the apps (container hostnames are gone, everything is 127.0.0.1)

- **Sonarr / Radarr** → Download clients: qBittorrent `127.0.0.1:8090`, SABnzbd `127.0.0.1:8085`.
- **Prowlarr** (fresh): add the indexers again, FlareSolverr proxy `http://127.0.0.1:8191`,
  apps Sonarr `http://127.0.0.1:8989` / Radarr `http://127.0.0.1:7878` (Prowlarr server `http://127.0.0.1:9696`).
- **Bazarr** → Sonarr/Radarr host `127.0.0.1`; delete the path mappings (`/tv`, `/movies`, `/anime`): Bazarr now sees the same `/arr/...` paths as Sonarr/Radarr.
- **Seerr** → Jellyfin `127.0.0.1:8096`, Sonarr `127.0.0.1:8989`, Radarr `127.0.0.1:7878`.
- **SABnzbd**: values set in Nix (`services/arr/sabnzbd.nix`) win over the copied ini at every start.
- **Suwayomi**: restore the `.tachibk` backup.
- **Frigate**: the first start prints the admin password in `journalctl -u frigate`.

## 7. Clean up (after a week or two without problems)

```bash
rm -rf /var/lib/docker /srv/stacks /root/migration
```
