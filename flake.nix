{
  description = "NixOS system configurations for AI workloads";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    {
      nixosConfigurations = {
        llm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/llm/configuration.nix ];
        };
      };
    };
}
