# Lightweight host observability — journald retention + node_exporter bound to
# localhost. Ported from nix-ai-server (modules/system/observability.nix).
# Log shipping is owned by `modules/monitoring/promtail.nix`.
{ config, lib, ... }:
{
  options.baseline.observability.enable = lib.mkEnableOption "journald retention + a localhost node_exporter";

  config = lib.mkIf config.baseline.observability.enable {
    services.journald.extraConfig = ''
      SystemMaxUse=2G
      MaxRetentionSec=14day
    '';

    services.prometheus.exporters.node = {
      enable = lib.mkDefault true;
      listenAddress = "127.0.0.1";
      port = 9100;
      enabledCollectors = [
        "systemd"
        "processes"
      ];
    };
  };
}
