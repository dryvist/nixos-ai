{
  description = "NixOS system configurations for AI workloads";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      sops-nix,
    }:
    let
      vars = import ./vars.nix;

      # Source-only + eval checks build on the CI system; scope them to the
      # Linux hosts so `nix flake check --all-systems` never tries to build a
      # Linux derivation from a darwin runner.
      checkSystems = builtins.filter (nixpkgs.lib.hasSuffix "-linux") vars.flake.formatterSystems;
    in
    {
      formatter = nixpkgs.lib.genAttrs vars.flake.formatterSystems (
        system: nixpkgs.legacyPackages.${system}.nixfmt-tree
      );

      checks = nixpkgs.lib.genAttrs checkSystems (
        system:
        import ./lib/checks.nix {
          pkgs = nixpkgs.legacyPackages.${system};
          inherit (self) nixosConfigurations;
          src = ./.;
        }
      );

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
}
