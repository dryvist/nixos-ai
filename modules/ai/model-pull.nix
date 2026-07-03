# Pre-pull a curated set of model artifacts at activation time. Ported from
# nix-ai-server (modules/ai/model-pull.nix).
#
# Real implementation will use a `huggingface-cli` systemd timer; the stub
# registers the option surface today.
{ config, lib, ... }:
{
  options.ai.model-pull = {
    enable = lib.mkEnableOption "scheduled HuggingFace model pre-pull";
    models = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "HuggingFace repo IDs to pre-pull, e.g. `meta-llama/Meta-Llama-3-8B-Instruct`.";
    };
  };

  config = lib.mkIf config.ai.model-pull.enable {
    assertions = [
      {
        assertion = config.ai.huggingface-cache.enable;
        message = "ai.model-pull.enable requires ai.huggingface-cache.enable.";
      }
      {
        assertion = false;
        message = "ai.model-pull.enable is currently a stub; the systemd timer lands in a follow-up PR.";
      }
    ];
  };
}
