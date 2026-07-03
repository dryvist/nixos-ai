# llama.cpp server stub. Ported from nix-ai-server (modules/ai/llama-cpp.nix).
#
# Currently exposes the binary on PATH (CPU/ROCm build from nixpkgs). A future
# PR adds a systemd unit bound to a HuggingFace cache path.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.ai.llama-cpp.enable = lib.mkEnableOption "the llama.cpp toolchain";

  config = lib.mkIf config.ai.llama-cpp.enable {
    environment.systemPackages = [ pkgs.llama-cpp ];
  };
}
