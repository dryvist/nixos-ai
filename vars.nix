# Per-operator values referenced by host configs. Public values only —
# private keys, API tokens, and TLS certs belong in agenix or sops-nix.
{
  ssh = {
    # Authorized public keys; rename handles to match your devices.
    mbp-m4-max = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILjM+Bt9dUre8Co8Fa2Ekvq+1l+Q/OxxNfWd4a8upcTX";
    secondary = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHYetaMztUaVpbgwVLfsCe6tTQ9Uu2kJptGKM2T0yKds";
  };
}
