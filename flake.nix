{
  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3.11.1";
    nixpkgs.follows = "nixos-cosmic/nixpkgs-stable";
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
    nixosConfigurations.darter = nixpkgs-master.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        determinate.nixosModules.default
        #microvm.nixosModules.host
        ./darter/configuration.nix
      ];
    };

    nixosConfigurations.macy = nixpkgs-master.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        #microvm.nixosModules.host
        ./macy/configuration.nix
      ];
    };
  };
}

