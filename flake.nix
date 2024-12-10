{
  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs.url = "github:NixOS/nixpkgs?rev=4637bf5b68943c5d694fdbd20652d496997f088d";
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
    };
  };

  outputs = { self, nixpkgs, nixos-cosmic, ... }@attrs:
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
        ./configuration.nix
      ] ++ cosmic-modules;
    };
  };
}

