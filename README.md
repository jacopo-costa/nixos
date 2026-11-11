# nixos

Personal NixOS flake for a handful of machines (desktops, laptops, homelab). One repo, one flake, a few shared modules.

## How it's organised

```
.
├── flake.nix          # nixosConfigurations + formatter, via the helpers below
├── flakeHelpers.nix   # mkNixos
│
├── hosts/
│   ├── _common/       # baseline every host gets (locale, nix, sops)
│   └── <host>/        # per-host: hardware, disko-config, host-specific bits
│
├── modules/           # reusable, option-driven NixOS modules
│   ├── desktop/       # Plasma 6, SDDM, PipeWire, etc. — toggled per host
│   ├── email/         # msmtp + sops-managed credentials
│   └── homelab/       # libvirt, smartd, power mgmt, Intel GPU, podman
│
├── services/          # self-hosted apps (freezer): one folder per app, no options
│
└── users/jacopo/      # NixOS user + Home Manager wire-up + home.nix
```

Each host's flake entry is built by `mkNixos`, which auto-imports `hosts/_common`, `hosts/<host>`, sops-nix, disko + the host's `disko-config.nix`, and merges any extra modules the host declares in `flake.nix`.

Modules expose `options.<name>.enable` (plus a few knobs) and only do anything when the host opts in — so the homelab module doesn't run on desktops, and the desktop module doesn't run on the server.

## Self-hosted apps (freezer)

`services/` has one folder per app, listed in `services/default.nix` (comment out a line to turn an app off).
It's plain config, not an option-driven module: freezer imports it in `flake.nix`. Each app file holds, top to bottom:

1. its sops secrets (and the env file built from them),
2. the NixOS service (`services.<app>`), or a podman container when nixpkgs has no module,
3. its Traefik route (`services.traefik.dynamicConfigOptions.http`).

Traefik terminates TLS (Cloudflare wildcard) and applies CrowdSec, rate limiting and security headers on
`*.dimoracosta.it` (`websecure`, :443). LAN-only apps are on `*.freezer.lan` (`weblocal`, :80, LAN source IPs only).
Apps listen on `127.0.0.1` only. Media and big data live on the ZFS pool `tank`; apps that use it never start without it.

The one-time migration from the old docker stacks is in `services/MIGRATION.md`.

## Home Manager

Wired in `users/jacopo/default.nix`, not in `flake.nix`. Reads `osConfig.<...>` to gate per-context bits (desktop-only packages only land on hosts that enable the desktop module).

## Secrets

[sops-nix](https://github.com/Mic92/sops-nix) with age. Encrypted store: `hosts/_common/secrets/secrets.yaml`. Each host needs the age private key at `/etc/sops/age/keys.txt` before the first rebuild — provision out of band.

## Disks

Declarative via [disko](https://github.com/nix-community/disko); each host has its own `disko-config.nix`.

## Inputs

Pinned in `flake.nix`, all following `nixpkgs`: `nixpkgs` (stable), `home-manager`, `disko`, `sops-nix`.

## Building

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

First-time install:

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode disko ./hosts/<hostname>/disko-config.nix

sudo nixos-install --flake .#<hostname>
```

## Formatting

```bash
nix fmt
```

[alejandra](https://github.com/kamadorueda/alejandra), exposed as the flake's `formatter` for the common systems via the `forAllSystems` helper.
