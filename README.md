# nixos

Personal NixOS flake for three machines: a desktop (`cooler`), a homelab server (`freezer`), and a laptop (`librovivo`).

## Hosts

| Host        | Role                | CPU/GPU | Boot loader   | Notable bits                                          |
| ----------- | ------------------- | ------- | ------------- | ----------------------------------------------------- |
| `cooler`    | Desktop / gaming    | AMD     | GRUB          | Steam, Gamemode, ROCm Ollama, OpenRGB, KDE Plasma     |
| `freezer`   | Homelab server      | Intel   | systemd-boot  | ZFS (`tank`), libvirt, Docker, Caddy + CrowdSec, sops |
| `librovivo` | Laptop              | AMD     | systemd-boot  | KDE Plasma, Italian keymap, no auto-reboot on upgrade |

All hosts share the `hosts/_common` module (locale `it_IT.UTF-8`, timezone `Europe/Rome`, Nix GC + optimise, zsh, weekly `system.autoUpgrade`, sops-nix, disko).

## Layout

```
.
├── flake.nix              # 3 nixosConfigurations via mkNixos
├── flakeHelpers.nix       # mkNixos + attr-merge helper
├── .sops.yaml             # age recipients for secrets.yaml
│
├── hosts/
│   ├── _common/           # shared baseline for every host
│   │   ├── nix/           # nix.gc, optimise, allowUnfree
│   │   └── secrets/       # sops defaults + secrets.yaml
│   ├── cooler/            # desktop host
│   │   ├── desktop/       # enables the `desktop` module (GRUB)
│   │   └── disko-config.nix
│   ├── freezer/           # homelab host
│   │   ├── email/         # configures the `email` module (msmtp)
│   │   ├── homelab/       # enables the `homelab` module + per-service flags
│   │   ├── network/       # bridge br0, static IP
│   │   ├── zfs/           # autoScrub, ZED email notifications
│   │   └── disko-config.nix
│   └── librovivo/         # laptop host
│       ├── desktop/       # enables the `desktop` module (systemd-boot)
│       └── disko-config.nix
│
├── desktop/               # `desktop` module: Plasma 6, SDDM, PipeWire, Flatpak, Zen
├── homelab/               # `homelab` module: shared user/group, libvirt, smartd, power mgmt
│   └── services/          # per-service submodules (Caddy, Pocket-ID, Vaultwarden, …)
├── modules/
│   └── email/             # `email` module: msmtp w/ sops-managed password
│
└── users/
    └── jacopo/            # system user + Home Manager config (zsh, git, oh-my-zsh)
```

### Module entry points

- `desktop/default.nix` — `options.desktop.{enable,grub,systemd-boot}`
- `homelab/default.nix` — `options.homelab.{enable,user,group,timeZone,baseDomain}`
- `homelab/services/default.nix` — `options.homelab.services.enable` + sets up Docker for OCI containers
- `modules/email/default.nix` — `options.email.{enable,fromAddress,toAddress,smtp*}`

### Homelab services

Defined under `homelab/services/`. The ones currently imported by `homelab/services/default.nix` are:

- `caddy` — reverse proxy with the Cloudflare DNS plugin and the CrowdSec bouncer plugin; pulls hub collections for Caddy / Linux / HTTP CVEs
- `pocket-id` — OIDC provider (runs as an OCI container behind Caddy)
- `vaultwarden` — password vault (native NixOS service behind Caddy with CrowdSec protection)

Additional service modules exist on disk (`immich`, `jellyfin`, `nextcloud`, `paperless`, `qbittorrent`, `ollama`, `open-webui`, `arr/*`) but are not currently wired into `homelab/services/default.nix`.

## Secrets

Managed with [sops-nix](https://github.com/Mic92/sops-nix) using age.

- Encrypted store: `hosts/_common/secrets/secrets.yaml`
- Recipient: see `.sops.yaml`
- Private key on each host: `/etc/sops/age/keys.txt` (`generateKey = false` — provision out of band)

Secrets currently consumed:

- `systemPasswords/jacopo` — login password hash for the `jacopo` user (`neededForUsers = true`)
- `smtp/{user,password}` — for the `email` module (msmtp) and Vaultwarden SMTP
- `cloudflareToken` — Caddy ACME DNS-01 challenge
- `crowdsecBouncerKey` — Caddy ↔ CrowdSec LAPI
- `pocket-id/{maxmindLicenseKey,encryptionKey}`
- `vaultwardenAdminToken`

Several of these are composed into `sops.templates` (e.g. `cloudflareEnv`, `pocketIdEnv`, `vaultwardenEnv`) which are then passed to services as `environmentFile`s.

## Disko

Disk layout is declarative via [disko](https://github.com/nix-community/disko). Each host has a `disko-config.nix` under `hosts/<host>/`. `freezer` uses ext4 root + ZFS for the `tank` pool (declared via `boot.zfs.extraPools`, not in the disko config itself).

## Inputs

Pinned in `flake.nix` (all follow `nixpkgs`):

- `nixpkgs` — `nixos-25.11`
- `home-manager` — `release-25.11`
- `disko`
- `sops-nix`
- `zen-browser` (desktop only)
- `flake-utils` (just to expose `formatter = alejandra`)

## Building

```bash
# from a checkout of this repo on the target host
sudo nixos-rebuild switch --flake .#<hostname>
```

where `<hostname>` is `cooler`, `freezer`, or `librovivo`.

First-time install (with disko) is roughly:

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode disko ./hosts/<hostname>/disko-config.nix

sudo nixos-install --flake .#<hostname>
```

After install, place the age private key at `/etc/sops/age/keys.txt` before the next rebuild so sops-managed users and services can decrypt.

## Auto-upgrade

`system.autoUpgrade` runs weekly (Sat 09:00 + up to 45 min jitter) on every host, updating the `nixpkgs` input from the flake. `librovivo` has `allowReboot = false` forced; the others use the default.

## Formatting

```bash
nix fmt
```

Uses [alejandra](https://github.com/kamadorueda/alejandra), exposed as the flake's `formatter` for `x86_64-linux`.
