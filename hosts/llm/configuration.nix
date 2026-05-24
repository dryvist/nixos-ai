{
  config,
  lib,
  pkgs,
  host,
  vars,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.kernelModules = [ host.gpu.initrdModule ];
    kernelModules = [ host.cpu.kvmModule ];
  };

  networking = {
    inherit (host) hostName;
    networkmanager.enable = true;
    firewall.enable = true;
  };

  time = {
    inherit (host) timeZone;
  };

  nix = {
    settings = {
      experimental-features = vars.nix.experimentalFeatures;
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = vars.nix.gcDates;
      options = vars.nix.gcOptions;
    };
  };

  zramSwap = {
    enable = true;
    memoryPercent = vars.resources.zramMemoryPercent;
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
    # ignoreIP covers trusted internal ranges; key-only SSH auth is the
    # real access control.
    fail2ban = {
      enable = true;
      maxretry = vars.security.fail2banMaxRetry;
      ignoreIP = host.network.trustedIpRanges;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = map (
    handle: vars.ssh.keys.${handle}
  ) host.rootSshKeyHandles;

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

  system = {
    inherit (host) stateVersion;
  };
}
