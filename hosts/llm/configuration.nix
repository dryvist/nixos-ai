{
  config,
  lib,
  pkgs,
  ...
}:

let
  vars = import ../../vars.nix;
in
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

  # Root authorized keys are pulled by name from vars.nix at the repo root.
  # Keys are committed (they're public by definition) so the flake evaluator
  # sees them; no gitignored sidecar file, no operator setup step.
  users.users.root.openssh.authorizedKeys.keys = [
    vars.ssh.mbp-m4-max
    vars.ssh.secondary
  ];

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
