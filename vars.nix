# Per-operator, per-site, per-host variables. Edit this file to fork the
# repo for your own hardware and preferences — the rest of the tree only
# references values defined here. See README for the add-a-host workflow.
#
# True secrets (private keys, API tokens, TLS certs) belong in agenix or
# sops-nix, never in this file.
{
  # SSH public keys. Each entry is a handle referenced from
  # hosts.<name>.rootSshKeyHandles below.
  ssh.keys = {
    mbp-m4-max = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILjM+Bt9dUre8Co8Fa2Ekvq+1l+Q/OxxNfWd4a8upcTX";
    secondary = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHYetaMztUaVpbgwVLfsCe6tTQ9Uu2kJptGKM2T0yKds";
  };

  hosts = {
    llm = {
      hostName = "llm";
      system = "x86_64-linux";
      stateVersion = "26.05"; # set at first install; do NOT bump
      timeZone = "UTC";

      cpu = {
        kvmModule = "kvm-amd";
        vendor = "amd"; # used for hardware.cpu.<vendor>.updateMicrocode
      };

      gpu.initrdModule = "amdgpu";

      # Disk UUIDs — get via `lsblk -f` after install.
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

      # Copy from `nixos-generate-config --show-hardware-config` on the target.
      initrdKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];

      rootSshKeyHandles = [
        "mbp-m4-max"
        "secondary"
      ];

      network.trustedIpRanges = [
        "10.0.0.0/8"
        "127.0.0.0/8"
      ];
    };
  };

  nix = {
    gcDates = "weekly";
    gcOptions = "--delete-older-than 14d";
    experimentalFeatures = [
      "nix-command"
      "flakes"
    ];
  };

  resources.zramMemoryPercent = 25;

  security.fail2banMaxRetry = 5;

  flake.formatterSystems = [
    "x86_64-linux"
    "aarch64-darwin"
  ];
}
