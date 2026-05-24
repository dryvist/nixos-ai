# Variables — values that vary by operator/site but don't merit their own
# Nix module. Imported by host configurations under hosts/<name>/.
#
# This file is committed. Public SSH keys go here (public by definition —
# OpenSSH publishes them in the SSH handshake). True secrets (private
# keys, API tokens, TLS certs) belong in agenix / sops-nix, not here.
{
  ssh = {
    # Operator's authorized public keys, one entry per device.
    # The names below are handles you can rename to match your devices;
    # nothing in the rest of the tree depends on a specific name.
    mbp-m4-max = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILjM+Bt9dUre8Co8Fa2Ekvq+1l+Q/OxxNfWd4a8upcTX";
    secondary = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHYetaMztUaVpbgwVLfsCe6tTQ9Uu2kJptGKM2T0yKds";
  };
}
