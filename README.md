# nixos

Personal NixOS flake for three machines: a desktop (`cooler`), a homelab server (`freezer`), and a laptop (`librovivo`).

## Hosts

| Host        | Role             | CPU/GPU | Boot loader  | Disk                       | Notable bits                                             |
| ----------- | ---------------- | ------- | ------------ | -------------------------- | -------------------------------------------------------- |
| `cooler`    | Desktop / gaming | AMD     | GRUB         | ext4 on `nvme0n1`          | Steam, Gamemode, ROCm Ollama, OpenRGB, KDE Plasma 6      |
| `freezer`   | Homelab server   | Intel   | systemd-boot | ext4 root + ZFS pool `tank`| systemd-networkd bridge, libvirt, Docker, smartd, sops   |
| `librovivo` | Laptop           | AMD     | systemd-boot | LUKS on `nvme0n1`, ext4    | KDE Plasma 6, Italian keymap, systemd-style initrd       |

All hosts share the `hosts/_common` module (locale `it_IT.UTF-8`, timezone `Europe/Rome`, Nix GC + optimise, zsh, sops-nix, disko, Home Manager via `users/jacopo`).

## Layout

```
.
├── flake.nix                # 3 nixosConfigurations via mkNixos + forAllSystems formatter
├── flakeHelpers.nix         # mkNixos + mergeOutputs helper
├── .sops.yaml               # age recipients for secrets.yaml
│
├── hosts/
│   ├── _common/             # shared baseline for every host
│   │   ├── nix/             # nix.gc, optimise, allowUnfree
│   │   └── secrets/         # sops defaults + secrets.yaml
│   ├── cooler/              # desktop host (AMD, GRUB, Steam, ROCm Ollama)
│   │   └── disko-config.nix
│   ├── freezer/             # homelab host
│   │   ├── email/           # configures the `email` module (msmtp)
│   │   ├── homelab/         # enables the `homelab` module + per-service flags
│   │   ├── network/         # systemd-networkd: br0 with enp3s0 enslaved
│   │   ├── zfs/             # autoScrub, autoSnapshot, ZED email notifications
│   │   └── disko-config.nix
│   └── librovivo/           # laptop host (AMD, systemd-boot, LUKS)
│       └── disko-config.nix
│
├── modules/
│   ├── desktop/             # Plasma 6, SDDM, PipeWire, Flatpak, plymouth silent boot
│   ├── email/               # msmtp w/ sops-managed password
│   └── homelab/             # shared user/group, libvirt, smartd, power mgmt
│       └── services/        # per-service submodules (WIP — see below)
│
└── users/
    └── jacopo/              # NixOS user + Home Manager wire-up + home.nix
```

### Module entry points

- `modules/desktop/default.nix` — `options.desktop.{enable,grub,systemd-boot}`
- `modules/homelab/default.nix` — `options.homelab.{enable,user,group,timeZone,baseDomain}`
- `modules/homelab/services/default.nix` — `options.homelab.services.enable` + sets up Docker for OCI containers
- `modules/email/default.nix` — `options.email.{enable,fromAddress,toAddress,smtp*}`

### Home Manager

Wired in `users/jacopo/default.nix` (imports the `home-manager.nixosModules.home-manager` module and sets `home-manager.users.jacopo = import ./home.nix`). Reads `osConfig.desktop.enable` to gate desktop-only packages (Zen Browser, VLC, nextcloud-client, jellyfin-media-player) so they only land on `cooler` and `librovivo`.

### Homelab services (WIP)

`modules/homelab/services/` contains submodules for Caddy (with CrowdSec bouncer + Cloudflare DNS plugin), Pocket-ID (OIDC), Vaultwarden, Immich, Jellyfin, Nextcloud, Paperless, qBittorrent, Ollama, Open-WebUI, and the *arr stack. **Currently being migrated from Docker to native NixOS modules** — most are present on disk but disabled in `hosts/freezer/homelab/default.nix` until reworked.

## Secrets

Managed with [sops-nix](https://github.com/Mic92/sops-nix) using age.

- Encrypted store: `hosts/_common/secrets/secrets.yaml`
- Recipient: see `.sops.yaml`
- Private key on each host: `/etc/sops/age/keys.txt` (`generateKey = false` — provision out of band before the first rebuild)

Secrets currently consumed:

- `systemPasswords/jacopo` — login password hash for the `jacopo` user (`neededForUsers = true`)
- `smtp/{user,password}` — for the `email` module (msmtp) and Vaultwarden SMTP
- `cloudflareToken` — Caddy ACME DNS-01 challenge
- `crowdsecBouncerKey` — Caddy ↔ CrowdSec LAPI
- `pocket-id/{maxmindLicenseKey,encryptionKey}`
- `vaultwardenAdminToken`

Several of these are composed into `sops.templates` (e.g. `cloudflareEnv`, `pocketIdEnv`, `vaultwardenEnv`) which are then passed to services as `environmentFile`s.

## Disko

Disk layout is declarative via [disko](https://github.com/nix-community/disko). Each host has a `disko-config.nix` under `hosts/<host>/`:

- `cooler` and `freezer` — plain ext4 root on `nvme0n1`. `freezer` additionally imports the ZFS `tank` pool via `boot.zfs.extraPools` (the pool itself is not declared in disko).
- `librovivo` — LUKS-encrypted root (mapper `cryptroot`), ext4 inside. `boot.initrd.systemd.enable = true` so the unlock prompt honors the Italian keymap and so TPM2/FIDO2 enrollment is possible post-install.

## Inputs

Pinned in `flake.nix` (all follow `nixpkgs`):

- `nixpkgs` — `nixos-25.11`
- `home-manager` — `release-25.11`
- `disko`
- `sops-nix`
- `zen-browser` (desktop hosts only, exposed to Home Manager via `extraSpecialArgs`)

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

For `librovivo`, disko prompts for the LUKS passphrase interactively during the `--mode disko` step. After install, optionally enroll the TPM and/or a recovery key with `systemd-cryptenroll` and add `boot.initrd.luks.devices.cryptroot.crypttabExtraOpts = ["tpm2-device=auto"];` to enable auto-unlock on trusted firmware state.

After install, place the age private key at `/etc/sops/age/keys.txt` before the next rebuild so sops-managed users and services can decrypt.

## Formatting

```bash
nix fmt
```

Uses [alejandra](https://github.com/kamadorueda/alejandra), exposed as the flake's `formatter` across `x86_64-linux`, `aarch64-linux`, `x86_64-darwin`, `aarch64-darwin` via the `forAllSystems` helper in `flake.nix`.
