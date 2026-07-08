# nixos-ai

System-level NixOS for AI hosts in the homelab — the counterpart to
[`JacobPEvans/nix-ai`](https://github.com/JacobPEvans/nix-ai), which is
user-level home-manager modules for AI CLI tooling.

## What belongs here

- NixOS host configurations under `hosts/<hostname>/`
- Shared NixOS modules under `modules/` — salvaged from nix-ai-server ahead of
  its archival (see [ADR 0001](docs/adr/0001-consolidate-on-nixos-ai.md)):
  `system/`, `ai/`, `secrets/`, `monitoring/`. Every module is behind an
  `enable` flag and off by default; none is wired into the `llm` host yet —
  that's [issue #8](https://github.com/dryvist/nixos-ai/issues/8), blocked on
  the cluster-guest hardware node joining.
- AI-workload system services (vLLM, llama.cpp, model servers) when added
- GPU stacks (amdgpu/ROCm) at the system layer

## What does NOT belong here

- Home-manager / user-level config →
  [`JacobPEvans/nix-ai`](https://github.com/JacobPEvans/nix-ai)
- macOS configs →
  [`JacobPEvans/nix-darwin`](https://github.com/JacobPEvans/nix-darwin)
- True secrets (private keys, API tokens, TLS certs) — those belong in
  agenix / sops-nix, never in `vars.nix` or any plain committed file

## Validation before push

```bash
nix flake check                       # evaluation + statix + deadnix + nixfmt
nixos-rebuild build --flake .#<host>  # build on target host or remote builder
```

For host-affecting changes, deploy and verify a fresh SSH session connects
before claiming done. `nixos-rebuild build` validates evaluation only — it
does not validate runtime behavior (services starting, kernel modules
loading, network coming up, etc.).

## Worktree workflow

Standard `~/git/` convention: bare repo at `~/git/nixos-ai/.git`, worktrees
at `~/git/nixos-ai/<type>/<name>/`. Run `/refresh-repo` before starting
new work.

## Tooling baseline (inherited from dryvist/.github)

Formatting, linting, and pre-commit hooks come from `dryvist/.github`'s
`flakeModules.dev-hygiene`, imported directly in `flake.nix` — not a synced
copy. See `nix/dev-hygiene.nix` in that repo for the canonical source.

- **Markdown lint:** `markdownlint-cli2` with the canonical
  `.markdownlint-cli2.yaml` synced from
  [`dryvist/.github`](https://github.com/dryvist/.github). `MD013
line_length: 160`; no 80-char heading/code restrictions; `MD024
siblings_only` scoped to `CHANGELOG.md` only.
- **Nix toolchain:** `nixfmt` (formatter), `statix` (lint), `deadnix`
  (dead code). All enforced in pre-commit; `lib/checks.nix` adds only the
  NixOS host-evaluation gate dev-hygiene doesn't cover.
- **Secrets:** `gitleaks` (pinned to v8.x via nixpkgs) — layered on top of
  dev-hygiene as a custom hook in `flake.nix`, since
  `cachix/git-hooks.nix` has no built-in gitleaks hook.
- **nixpkgs channel:** `nixos-unstable` — keeps `markdownlint-cli2` at a
  version that supports `MD060` natively; we do not work around stale
  tooling by disabling rules.

Do NOT commit local copies of `.markdownlint-cli2.{jsonc,yaml}` that drift
from the dryvist canonical, and do NOT re-introduce leniency rules to
work around stale tooling — fix the tooling instead.
