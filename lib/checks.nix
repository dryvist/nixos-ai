# Single source of truth for `nix flake check` outputs: formatting + static
# analysis + dead-code detection + a NixOS toplevel evaluation gate.
# Ported from nix-ai-server (lib/checks.nix).
{
  pkgs,
  src,
  nixosConfigurations ? { },
}:
{
  formatting =
    pkgs.runCommand "check-formatting"
      {
        nativeBuildInputs = [ pkgs.nixfmt-rfc-style ];
      }
      ''
        cp -r ${src} $TMPDIR/src
        chmod -R u+w $TMPDIR/src
        cd $TMPDIR/src
        ${pkgs.lib.getExe pkgs.nixfmt-rfc-style} --check $(find . -type f -name '*.nix')
        touch $out
      '';

  statix = pkgs.runCommand "check-statix" { } ''
    cd ${src}
    ${pkgs.lib.getExe pkgs.statix} check .
    touch $out
  '';

  deadnix = pkgs.runCommand "check-deadnix" { } ''
    cd ${src}
    ${pkgs.lib.getExe pkgs.deadnix} -L --fail .
    touch $out
  '';
}
// pkgs.lib.optionalAttrs (nixosConfigurations != { }) {
  # Evaluate every NixOS host to catch import errors, type errors, and
  # assertion failures without performing a full system build.
  #
  # unsafeDiscardStringContext is load-bearing: computing drvPath forces full
  # evaluation of each host's module system (the gate we want), but keeping
  # the string context would register the system .drv as an input of this
  # check derivation. Determinate Nix >= 3.21 no longer guarantees the .drv
  # is written to the store during evaluation, so `nix flake check --no-build`
  # fails with "path '...-nixos-system-*.drv' is not valid". Discarding the
  # context keeps the check eval-only with no store dependency.
  module-eval = pkgs.runCommand "check-module-eval" { } ''
    ${pkgs.lib.concatStringsSep "\n" (
      pkgs.lib.mapAttrsToList (
        name: cfg:
        "echo \"${name}: ${builtins.unsafeDiscardStringContext cfg.config.system.build.toplevel.drvPath}\""
      ) nixosConfigurations
    )}
    touch $out
  '';
}
