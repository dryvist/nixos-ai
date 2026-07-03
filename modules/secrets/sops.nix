# sops-nix: decrypt activation-time secrets to /run/secrets/. Ported from
# nix-ai-server (modules/secrets/sops.nix).
#
# Activation-time secrets are SHORT-LIVED bootstrap material — host join
# tokens, the OpenBao agent's initial AppRole secret-id, etc. Anything an AI
# service consumes at runtime should come from the OpenBao agent
# (modules/secrets/openbao-agent.nix), not from here.
#
# Opt-in: the `sops` option namespace is provided by sops-nix.nixosModules.sops
# (imported in flake.nix). Enabling this without a derived host age key + a
# `secrets/*.enc.yaml` file will fail at activation, so it stays off until a
# host is ready to consume secrets.
{ config, lib, ... }:
{
  options.secrets.sops.enable = lib.mkEnableOption "sops-nix activation-time secret decryption";

  config = lib.mkIf config.secrets.sops.enable {
    sops = {
      age = {
        keyFile = lib.mkDefault "/var/lib/sops-nix/keys.txt";
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
      defaultSopsFormat = "yaml";

      # Per-secret declarations land alongside the OpenBao AppRole bootstrap
      # material in a follow-up PR.
      secrets = { };
    };

    # Surface a helpful error if anyone enables this on a host that hasn't yet
    # had its age key derived via `ssh-to-age`.
    assertions = [
      {
        assertion = config.sops.age.keyFile != null;
        message = "sops.age.keyFile must point at the host age key (derived via ssh-to-age after first install).";
      }
    ];
  };
}
