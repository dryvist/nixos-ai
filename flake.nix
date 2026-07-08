{
  description = "NixOS system configurations for AI workloads";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Org-wide dev-hygiene (treefmt + pre-commit + zizmor) is imported as a
    # flake-module from dryvist/.github (see imports below). That flake is
    # lean — treefmt-nix + git-hooks only — so this stays free of the
    # devenv / crate2nix / devshell baggage nix-devenv would drag in, while
    # keeping the config in one org-wide home instead of inlined here.
    dryvist-github = {
      url = "github:dryvist/.github";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      sops-nix,
      flake-parts,
      ...
    }:
    let
      vars = import ./vars.nix;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = vars.flake.formatterSystems;

      imports = [
        inputs.dryvist-github.flakeModules.dev-hygiene
      ];

      flake = {
        nixosConfigurations = nixpkgs.lib.mapAttrs (
          name: host:
          nixpkgs.lib.nixosSystem {
            inherit (host) system;
            specialArgs = { inherit host vars; };
            modules = [
              sops-nix.nixosModules.sops
              ./modules
              ./hosts/${name}/configuration.nix
            ];
          }
        ) vars.hosts;
      };

      perSystem =
        {
          system,
          pkgs,
          lib,
          ...
        }:
        {
          # dev-hygiene's git-hooks import covers formatting/statix/deadnix/
          # markdownlint/zizmor via predefined hooks, but cachix/git-hooks.nix
          # ships detect-private-keys + trufflehog for secret scanning, not
          # gitleaks. Layer gitleaks on top as a custom "system" hook so the
          # v8.x pin this repo's AGENTS.md commits to keeps running.
          pre-commit.settings.hooks.gitleaks = {
            enable = true;
            name = "gitleaks";
            # `detect --no-git` scans the checked-out tree directly rather than
            # staged git diffs — the pre-commit-check derivation's sandbox has
            # no `.git` history for `gitleaks git --pre-commit` to read.
            entry = "${pkgs.gitleaks}/bin/gitleaks detect --no-git --source . --redact -v";
            language = "system";
            pass_filenames = false;
          };

          # NixOS host-evaluation gate: not covered by dev-hygiene, which is
          # source-only (formatting/lint/secrets). Scoped to Linux since these
          # are Linux system closures; darwin has nothing to evaluate here.
          checks = lib.optionalAttrs (lib.hasSuffix "-linux" system) {
            module-eval = import ./lib/checks.nix {
              inherit pkgs;
              inherit (self) nixosConfigurations;
            };
          };
        };
    };
}
