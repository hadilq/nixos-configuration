{
  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3.11.1";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, determinate, nixpkgs, nixos-cosmic, microvm, ... }@attrs:
  let
    cosmic-modules = [
      {
        nix.settings = {
          substituters = [ "https://cosmic.cachix.org/" ];
          trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
        };
      }
      nixos-cosmic.nixosModules.default
    ];
  in
  {
    nixosConfigurations.darter = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        determinate.nixosModules.default
        microvm.nixosModules.host
        ./configuration.nix
      ] ++ cosmic-modules;
    };
  };
}

