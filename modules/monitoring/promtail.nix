# Promtail: ship journald + AI-service stdout to the cluster's Loki. Ported
# from nix-ai-server (modules/monitoring/promtail.nix).
{ config, lib, ... }:
{
  options.monitoring.promtail = {
    enable = lib.mkEnableOption "Promtail journald shipping to the cluster Loki";
    lokiUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://loki.example.local:3100/loki/api/v1/push";
      description = "Loki push endpoint reachable from the host.";
    };
  };

  config = lib.mkIf config.monitoring.promtail.enable {
    services.promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 9080;
          grpc_listen_port = 0;
        };
        positions.filename = "/var/lib/promtail/positions.yaml";
        clients = [ { url = config.monitoring.promtail.lokiUrl; } ];
        scrape_configs = [
          {
            job_name = "journal";
            journal = {
              max_age = "12h";
              labels = {
                job = "systemd-journal";
                host = config.networking.hostName;
              };
            };
            relabel_configs = [
              {
                source_labels = [ "__journal__systemd_unit" ];
                target_label = "unit";
              }
            ];
          }
        ];
      };
    };
  };
}
