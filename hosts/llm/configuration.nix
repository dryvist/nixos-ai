{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.kernelModules = [ "amdgpu" ];
    kernelModules = [ "kvm-amd" ];
  };

  # NetworkManager owns DHCP
  networking = {
    hostName = "llm";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # UTC everywhere — homelab convention
  time.timeZone = "UTC";

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # zram swap — modest, for general responsiveness; no on-disk swap
  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  # AMD GPU userspace + early KMS via initrd amdgpu module above
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services = {
    # SSH — key-only, root via key
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
    # SSH brute-force defense — RFC1918 10.0.0.0/8 ignored to cover the
    # multi-VLAN internal homelab boundary; real access control is key-only.
    fail2ban = {
      enable = true;
      maxretry = 5;
      ignoreIP = [
        "10.0.0.0/8"
        "127.0.0.0/8"
      ];
    };
  };

  # sshkey is gitignored; copy hosts/llm/sshkey.example → hosts/llm/sshkey
  # and paste your authorized public keys before nixos-rebuild switch.
  # The lib.optional guard lets the flake evaluate cleanly on a fresh
  # clone where sshkey doesn't exist yet.
  users.users.root.openssh.authorizedKeys.keyFiles =
    lib.optional (builtins.pathExists ./sshkey) ./sshkey;

  environment.systemPackages = with pkgs; [
    git
    vim
    tmux
    htop
    pciutils
    usbutils
    lshw
    lm_sensors
    nvme-cli
    smartmontools
    iperf3
    mtr
    tcpdump
    rsync
    curl
    wget
    file
    tree
  ];

  system.stateVersion = "26.05";
}
