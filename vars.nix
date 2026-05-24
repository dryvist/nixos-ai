# Per-operator, per-site, per-host variables. Edit this file to fork the
# repo for your own hardware and preferences — the rest of the tree only
# references values defined here.
#
# True secrets (private keys, API tokens, TLS certs) belong in agenix or
# sops-nix, never in this file.
{
  # SSH public keys (public by definition; safe to commit). Each entry is
  # a handle referenced from hosts.<name>.rootSshKeyHandles below.
  ssh.keys = {
    mbp-m4-max = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILjM+Bt9dUre8Co8Fa2Ekvq+1l+Q/OxxNfWd4a8upcTX";
    secondary = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHYetaMztUaVpbgwVLfsCe6tTQ9Uu2kJptGKM2T0yKds";
  };

  # Per-host configuration. To bring up a new host:
  #   1. add an entry under `hosts.<name>` with the values below
  #   2. create `hosts/<name>/configuration.nix` and
  #      `hosts/<name>/hardware-configuration.nix` (the existing `llm`
  #      copies are a working template)
  #   3. `sudo nixos-rebuild switch --flake .#<name>` on the target host
  hosts = {
    llm = {
      # Identity
      hostName = "llm";
      system = "x86_64-linux";
      stateVersion = "26.05"; # NixOS release at first install; do NOT bump
      timeZone = "UTC";

      # CPU
      cpu = {
        kvmModule = "kvm-amd"; # kvm-amd or kvm-intel
        microcodeVendor = "amd"; # amd or intel
      };

      # GPU
      gpu.initrdModule = "amdgpu"; # amdgpu, nouveau, i915, …

      # Disks — get UUIDs via `lsblk -f` after install
      disks = {
        root = {
          uuid = "2ca0b9a3-b4ec-4176-ac9a-bacac9581cb2";
          fsType = "ext4";
        };
        boot = {
          uuid = "6FB4-E38A";
          fsType = "vfat";
          options = [
            "fmask=0022"
            "dmask=0022"
          ];
        };
      };

      # initrd kernel modules — copy from the output of
      # `nixos-generate-config --show-hardware-config | grep availableKernelModules`
      # on the target host so the boot stage can see the disks.
      initrdKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];

      # Root SSH keys — values are handles into ssh.keys above
      rootSshKeyHandles = [
        "mbp-m4-max"
        "secondary"
      ];

      # Networking
      network = {
        # CIDRs trusted as "internal" — fail2ban skips bans for sources in
        # these ranges. Key-only SSH remains the real access control.
        trustedIpRanges = [
          "10.0.0.0/8"
          "127.0.0.0/8"
        ];
      };
    };
  };

  # Nix daemon policies (applied to every host)
  nix = {
    gcDates = "weekly";
    gcOptions = "--delete-older-than 14d";
    experimentalFeatures = [
      "nix-command"
      "flakes"
    ];
  };

  # Resource tunings
  resources.zramMemoryPercent = 25;

  # Security tunings
  security.fail2banMaxRetry = 5;

  # Flake-level
  flake.formatterSystems = [
    "x86_64-linux"
    "aarch64-darwin"
  ];
}
