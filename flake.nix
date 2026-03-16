{
  description = "NixOS baremetal configuration";

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3.13";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, determinate, nixpkgs, microvm, ... }@attrs:
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

    nixosConfigurations.macy = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        #microvm.nixosModules.host
        ./macy/configuration.nix
      ];
    };
  };
}

