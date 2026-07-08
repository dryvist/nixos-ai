# NixOS host-evaluation gate. Formatting, statix, deadnix, markdownlint, and
# zizmor are covered by the org-wide dev-hygiene flakeModule (flake.nix); this
# file only carries the check dev-hygiene can't provide — evaluating every
# NixOS host to catch import errors, type errors, and assertion failures
# without performing a full system build.
{
  pkgs,
  nixosConfigurations ? { },
}:
pkgs.runCommand "check-module-eval" { } ''
  ${pkgs.lib.concatStringsSep "\n" (
    pkgs.lib.mapAttrsToList (
      name: cfg:
      # unsafeDiscardStringContext is load-bearing: computing drvPath forces
      # full evaluation of each host's module system (the gate we want), but
      # keeping the string context would register the system .drv as an
      # input of this check derivation. Determinate Nix >= 3.21 no longer
      # guarantees the .drv is written to the store during evaluation, so
      # `nix flake check --no-build` fails with "path '...-nixos-system-*.drv'
      # is not valid". Discarding the context keeps the check eval-only with
      # no store dependency.
      "echo \"${name}: ${builtins.unsafeDiscardStringContext cfg.config.system.build.toplevel.drvPath}\""
    ) nixosConfigurations
  )}
  touch $out
''
