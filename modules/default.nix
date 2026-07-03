# Aggregator: every module file under modules/ is imported here so any host
# that imports `./modules` from flake.nix picks up the full option surface.
# Every module is behind an `enable` flag and off by default — importing this
# changes nothing until a host opts a module in.
#
# Salvaged from nix-ai-server ahead of that repo's archival. The source's
# GPU-vendor and model-server modules are intentionally excluded — the
# accelerator story here is amdgpu/ROCm only.
{
  imports = [
    ./system/ssh.nix
    ./system/sudo.nix
    ./system/fail2ban.nix
    ./system/auto-upgrade.nix
    ./system/nix-settings.nix
    ./system/locale-time.nix
    ./system/observability.nix

    ./ai/nix-ld.nix
    ./ai/python.nix
    ./ai/llama-cpp.nix
    ./ai/huggingface-cache.nix
    ./ai/model-pull.nix

    ./secrets/sops.nix
    ./secrets/openbao-agent.nix

    ./monitoring/promtail.nix
  ];
}
