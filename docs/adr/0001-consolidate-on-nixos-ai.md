# ADR 0001: Consolidate the AI-host flake on nixos-ai; archive nix-ai-server

- Status: Accepted
- Date: 2026-07-03

## Context

`nix-ai-server` was a NixOS flake for a planned bare-metal, GPU-equipped AI
host: NVIDIA/CUDA driver modules, vLLM, Ollama, llama.cpp, JupyterHub, and a
standalone (never-cluster-member) networking story. The hardware it targeted
never materialized, and the accelerator plan changed — the actual GPU stack
available to this homelab is AMD/ROCm, not NVIDIA/CUDA. `nixos-ai` is the
sibling flake for NixOS AI hosts already in service (the `llm` host).

Keeping both repos active duplicated the system-module surface (SSH, sudo,
fail2ban, auto-upgrade, secrets, observability, AI tooling) across two flakes
with diverging accelerator assumptions, and `nix-ai-server`'s CUDA/vLLM/Ollama/
JupyterHub modules and bare-metal host stub had no path to ever building
against real hardware.

## Decision

Consolidate on `nixos-ai`:

- `nixos-ai` PR [#6](https://github.com/dryvist/nixos-ai/pull/6) dropped the
  NVIDIA/CUDA references from this repo's own docs — the accelerator story
  here is amdgpu/ROCm only.
- `nixos-ai` PR [#7](https://github.com/dryvist/nixos-ai/pull/7) salvaged
  `nix-ai-server`'s generic, accelerator-agnostic modules (`system/*`,
  `ai/nix-ld.nix`, `ai/python.nix`, `ai/llama-cpp.nix`,
  `ai/huggingface-cache.nix`, `ai/model-pull.nix`, `secrets/*`,
  `monitoring/promtail.nix`) into `modules/` ahead of `nix-ai-server`'s
  archival. The source's GPU-vendor (NVIDIA/CUDA) and model-server modules
  that assumed that vendor (vLLM, Ollama, JupyterHub) were intentionally
  excluded, not ported.
- `nix-ai-server` is archived. Its content is now either duplicated here
  (the generic modules) or obsolete under the ROCm pivot (the CUDA-specific
  modules and the bare-metal `ai-server-a` host stub, which never built
  against real hardware).
- Recreating an AI-workload guest is tracked as
  [issue #8](https://github.com/dryvist/nixos-ai/issues/8): define a NixOS
  guest (VM or LXC) on the virtualization cluster, once the new hardware node
  joins, using the modules salvaged in PR #7. Every salvaged module is behind
  `lib.mkEnableOption` and off by default — none is wired into a host yet.

## Consequences

- All future NixOS AI-host and AI-guest work happens in `nixos-ai`.
  `nix-ai-server` is frozen as read-only history; do not resume development
  there.
- The salvaged modules in `modules/` are inert until issue #8 lands — they
  exist and evaluate cleanly (see `lib/checks.nix`'s module-eval gate) but
  are not enabled by any `hosts/<name>/configuration.nix` today.
- `hosts/ai-server-a` from `nix-ai-server` is **not** ported here — it was a
  placeholder for hardware that was never built, and is obsolete under this
  pivot. The eventual cluster-guest host under `hosts/` (issue #8) starts
  fresh against real hardware-configuration output, not that stub.
- If a future host needs an NVIDIA/CUDA accelerator, that is a new decision
  to revisit, not a reason to un-archive `nix-ai-server`.
