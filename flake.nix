{
  description = "NixOS system configurations for AI workloads";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      vars = import ./vars.nix;
    in
    {
      formatter = nixpkgs.lib.genAttrs vars.flake.formatterSystems (
        system: nixpkgs.legacyPackages.${system}.nixfmt-tree
      );

      nixosConfigurations = nixpkgs.lib.mapAttrs (
        name: host:
        nixpkgs.lib.nixosSystem {
          inherit (host) system;
          specialArgs = { inherit host vars; };
          modules = [ ./hosts/${name}/configuration.nix ];
        }
      ) vars.hosts;
    };
}
