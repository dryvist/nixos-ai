# Brute-force mitigation for the SSH service. Ported from nix-ai-server
# (modules/system/fail2ban.nix).
#
# Opt-in library module: the `llm` host configures fail2ban inline today, so
# this stays off by default.
{ config, lib, ... }:
{
  options.baseline.fail2ban.enable = lib.mkEnableOption "the fail2ban baseline";

  config = lib.mkIf config.baseline.fail2ban.enable {
    services.fail2ban = {
      enable = true;
      maxretry = 5;
      bantime = "1h";
      bantime-increment = {
        enable = true;
        multipliers = "1 2 4 8 16 32 64";
        maxtime = "168h";
        overalljails = lib.mkDefault true;
      };
      jails.sshd.settings = {
        enabled = true;
        port = "ssh";
      };
    };
  };
}
