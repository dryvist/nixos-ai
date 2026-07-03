# Hardened OpenSSH defaults. Ported from nix-ai-server (modules/system/ssh.nix).
#
# Opt-in library module: the `llm` host configures OpenSSH inline today, so
# this stays off by default and is available for hosts that prefer the module.
{ config, lib, ... }:
{
  options.baseline.ssh.enable = lib.mkEnableOption "the hardened OpenSSH baseline";

  config = lib.mkIf config.baseline.ssh.enable {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = lib.mkDefault "prohibit-password";
        X11Forwarding = false;
      };
      openFirewall = true;
    };
  };
}
