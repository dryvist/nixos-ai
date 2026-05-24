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

  networking = {
    hostName = "llm";
    networkmanager.enable = true;
    firewall.enable = true;
  };

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

  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  hardware.graphics.enable = true;

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
    # ignoreIP covers the multi-VLAN internal homelab boundary; real
    # access control is key-only auth.
    fail2ban = {
      enable = true;
      maxretry = 5;
      ignoreIP = [
        "10.0.0.0/8"
        "127.0.0.0/8"
      ];
    };
  };

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
