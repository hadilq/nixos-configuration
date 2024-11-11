{
  inputs = {
    nixpkgs.follows = "nixos-cosmic/nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, nixos-cosmic, ... }@attrs:
  let
    cosmic-enabled = true;
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
      specialArgs = attrs // { inherit cosmic-enabled; };
      modules = [
        ./configuration.nix
        nixos-hardware.nixosModules.common-pc
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-laptop-ssd
      ] ++ nixpkgs.lib.optionals cosmic-enabled cosmic-modules;
    };
  };
}

