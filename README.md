# nixos-ai

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

NixOS system configurations for AI workloads — LLM inference hosts,
ROCm accelerator stacks, model-serving services — declared as flakes.

## What this is

The system-level counterpart to
[`nix-ai`](https://github.com/JacobPEvans/nix-ai) (home-manager modules
for Claude Code / Gemini / Copilot / MCP servers). `nixos-ai` holds NixOS
configurations for the physical Linux hosts that run AI workloads.

## Hosts

| Host | Hardware | Role | Status |
| --- | --- | --- | --- |
| `llm` | B550M Gaming X Wifi6 + Ryzen 9 5900X + 32 GB DDR4 + RX 580 + ADATA 512 GB NVMe | LLM inference / general AI dev | Active (NixOS 26.05) |

## Installation

Prerequisites:

- [Nix](https://nixos.org/) with flakes enabled
  (`experimental-features = nix-command flakes`)
- A NixOS host matching one of the hardware configurations under `hosts/`,
  or a derivative you maintain in a fork

Clone the repo onto the target host (typical path is `/etc/nixos`):

```bash
sudo git clone https://github.com/JacobPEvans/nixos-ai.git /etc/nixos
cd /etc/nixos
```

Edit `vars.nix` at the repo root for your fork. Everything that varies
per install lives there — SSH keys, disk UUIDs, hostname, timezone,
CPU/GPU module names, initrd modules, trusted IP ranges, gc schedule,
zram percentage, fail2ban retry count, supported formatter systems. The
rest of the tree only references values from `vars.nix`; there are no
hardcoded UUIDs, hostnames, or per-host magic numbers in the Nix
modules.

To bring up a new host:

1. Add an entry under `vars.hosts.<name>` (copy the `llm` block as a
   starting template).
2. Drop in `hosts/<name>/configuration.nix` and
   `hosts/<name>/hardware-configuration.nix` (copy the `llm` files;
   they only reference `host.*` and `vars.*`, no per-host hardcoding).
3. `sudo nixos-rebuild switch --flake .#<name>` on the target host.

The flake auto-discovers hosts via `nixpkgs.lib.mapAttrs` over
`vars.hosts`, so no `flake.nix` edit is needed when adding a host.

## Usage

Build and switch the active system on the target host:

```bash
sudo nixos-rebuild switch --flake .#llm
```

Build without persisting (validates evaluation + closure):

```bash
nixos-rebuild build --flake .#llm
```

Build directly from GitHub without cloning (useful for one-shot testing
on a fresh host):

```bash
sudo nixos-rebuild switch --flake github:JacobPEvans/nixos-ai#llm
```

Verify after switch:

```bash
systemctl is-active sshd fail2ban
timedatectl   # should print 'Time zone: UTC'
swapon --show # zram0 priority 5
```

## Conventions

- Hostnames are short, lowercase, single-word per host's primary role
  (`llm`, future `inference-N`).
- Timezone is UTC on every host.
- Root SSH is key-only; password and keyboard-interactive auth are disabled.
- All per-install and per-operator values (SSH keys, disk UUIDs,
  hostname, timezone, CPU/GPU module names, initrd modules, trusted IP
  ranges, gc schedule, zram %, fail2ban retry count) live in `vars.nix`
  at the repo root and flow into modules via `specialArgs` as `host` and
  `vars`. The Nix modules contain no per-host magic numbers — only
  policy decisions like "use systemd-boot" or "NetworkManager owns DHCP".
  `vars.nix` is committed; only publishable values belong there.
- `fail2ban` guards sshd; the RFC1918 `10.0.0.0/8` range is in `ignoreIP`
  to cover the multi-VLAN homelab boundary. Key-only auth is the actual
  access control.
- One flake at the repo root; per-host config lives in `hosts/<hostname>/`.

## Validation

```bash
nix flake check                       # evaluation + formatting + lint
nixos-rebuild build --flake .#llm     # build (no switch)
```

Pre-commit hooks check whitespace, YAML/JSON syntax, large files,
private-key leaks, markdown lint (markdownlint-cli2), Nix formatting
(nixfmt-rfc-style), unused bindings (deadnix), common antipatterns
(statix), and GitHub Actions security (zizmor).

```bash
pre-commit install                    # one-time setup
pre-commit run --all-files            # run all hooks
```

## Related repos

- [`nix-ai`](https://github.com/JacobPEvans/nix-ai) — user-level AI tooling
  (Claude Code, Gemini, Copilot, MCP servers) as home-manager modules.
- [`nix-darwin`](https://github.com/JacobPEvans/nix-darwin) — macOS system
  configurations.
- [`nix-home`](https://github.com/JacobPEvans/nix-home) — cross-platform
  home-manager user environment.
- [`nix-devenv`](https://github.com/JacobPEvans/nix-devenv) — reusable
  per-language dev shells.

## License

[MIT](LICENSE)
