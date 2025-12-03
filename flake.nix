{
  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3.13";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-master.url = "github:nixos/nixpkgs/dbc2252f27e4125f5ceb8bdaa0091d3e4d78edd0";
    #nixpkgs-master.follows = "nixos-cosmic/nixpkgs";
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
    };
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, determinate, nixpkgs, nixpkgs-master, nixos-cosmic, microvm, ... }@attrs:
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

