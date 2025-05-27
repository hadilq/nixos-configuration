{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
    };
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-cosmic, microvm, ... }@attrs:
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
        microvm.nixosModules.host
        ./configuration.nix
      ] ++ cosmic-modules;
    };
  };
}

