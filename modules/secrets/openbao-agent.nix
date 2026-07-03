# OpenBao agent driving runtime secrets into /run/openbao/*.env. Ported from
# nix-ai-server (modules/secrets/openbao-agent.nix).
#
# Architecture: a systemd timer runs `bao agent` every N minutes, which pulls
# short-TTL secrets from the cluster's OpenBao service and writes them to
# root-only files under `/run/openbao/`. AI service units
# `EnvironmentFile=/run/openbao/<service>.env` to consume them.
#
# Stub today: real timer + bao binary + AppRole bootstrap land in a follow-up
# PR. The option surface is committed now so per-service modules can already
# declare `secrets.openbao-agent.envFiles`.
{ config, lib, ... }:
{
  options.secrets.openbao-agent = {
    enable = lib.mkEnableOption "the OpenBao agent for runtime secret delivery";

    address = lib.mkOption {
      type = lib.types.str;
      default = "https://openbao.example.local:8200";
      description = "OpenBao API endpoint reachable from the host's LAN.";
    };

    envFiles = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              path = lib.mkOption {
                type = lib.types.str;
                default = "/run/openbao/${name}.env";
                description = "Where the rendered env file lands; consume via systemd EnvironmentFile=.";
              };
              template = lib.mkOption {
                type = lib.types.lines;
                description = "OpenBao agent template body (Vault-API compatible).";
              };
            };
          }
        )
      );
      default = { };
      description = "Per-service rendered env files driven by the OpenBao agent.";
    };
  };

  config = lib.mkIf config.secrets.openbao-agent.enable {
    assertions = [
      {
        assertion = false;
        message = "secrets.openbao-agent.enable is a stub today; the systemd timer + bao binary land in a follow-up PR.";
      }
    ];

    systemd.tmpfiles.rules = [
      "d /run/openbao 0700 root root - -"
    ];
  };
}
