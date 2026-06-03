{
  description = "NixOS baremetal configuration";

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3.21";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    microvm = {
      url = "github:astro/microvm.nix/0d49083ba2d7419b22908ac392777c16df9a032e";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      determinate,
      nixpkgs,
      microvm,
      ...
    }@attrs:
    {
      nixosConfigurations.darter = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          determinate.nixosModules.default
          #microvm.nixosModules.host
          ./darter/configuration.nix
        ];
      };

      nixosConfigurations.mini = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          ./mini/configuration.nix
        ];
      };

      nixosConfigurations.macy = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          #microvm.nixosModules.host
          ./macy/configuration.nix
        ];
      };

      formatter."x86_64-linux" = nixpkgs.legacyPackages."x86_64-linux".nixfmt-tree;
    };
}
