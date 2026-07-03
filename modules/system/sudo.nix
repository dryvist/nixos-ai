# sudo policy: wheel group only, password required by default. Ported from
# nix-ai-server (modules/system/sudo.nix). Individual host modules may grant
# passwordless sudo for specific automation accounts via
# `security.sudo.extraRules`.
{ config, lib, ... }:
{
  options.baseline.sudo.enable = lib.mkEnableOption "the hardened sudo baseline";

  config = lib.mkIf config.baseline.sudo.enable {
    security.sudo = {
      enable = true;
      wheelNeedsPassword = lib.mkDefault true;
      execWheelOnly = true;
    };
  };
}
