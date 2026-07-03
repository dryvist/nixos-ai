# Pull-mode auto-upgrade. Ported from nix-ai-server (modules/system/auto-upgrade.nix).
#
# The host rebuilds against this flake once a week and reboots if the kernel
# changed. Opt-in and off by default; the reboot window is intentionally
# narrow so an unattended reboot can't surprise a running workload.
{ config, lib, ... }:
{
  options.baseline.autoUpgrade.enable = lib.mkEnableOption "weekly pull-mode auto-upgrade";

  config = lib.mkIf config.baseline.autoUpgrade.enable {
    system.autoUpgrade = {
      enable = true;
      flake = "github:dryvist/nixos-ai#${config.networking.hostName}";
      flags = [
        "--update-input"
        "nixpkgs"
        "--no-write-lock-file"
        "-L"
      ];
      dates = "Sun 03:00";
      randomizedDelaySec = "45min";
      allowReboot = lib.mkDefault true;
      rebootWindow = {
        lower = "03:00";
        upper = "05:00";
      };
    };
  };
}
