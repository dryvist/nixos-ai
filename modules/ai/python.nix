# Python toolchain for AI workloads. Ported from nix-ai-server
# (modules/ai/python.nix).
#
# Exposes the bare interpreter + uv CLI on the system PATH so escape-hatch
# installs ("uv pip install ...") and notebooks work even outside a
# reproducible closure.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.ai.python.enable = lib.mkEnableOption "the system-level Python + uv toolchain";

  config = lib.mkIf config.ai.python.enable {
    environment.systemPackages = with pkgs; [
      python3
      uv
    ];
  };
}
