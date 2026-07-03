# Nix daemon settings: flakes, generous build resources for AI builds, and
# weekly garbage collection so model closures don't pile up. Ported from
# nix-ai-server (modules/system/nix-settings.nix).
#
# Opt-in library module: the `llm` host sets its Nix settings inline today, so
# this stays off by default to avoid double-defining them.
{ config, lib, ... }:
{
  options.baseline.nixSettings.enable = lib.mkEnableOption "the Nix daemon baseline settings";

  config = lib.mkIf config.baseline.nixSettings.enable {
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
        trusted-users = [
          "root"
          "@wheel"
        ];
        max-jobs = "auto";
        cores = 0;
      };

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };

      optimise = {
        automatic = true;
        dates = [ "weekly" ];
      };
    };
  };
}
