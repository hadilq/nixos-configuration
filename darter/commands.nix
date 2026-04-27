{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "deploy-minipc" ''
      set -e
      nixos-rebuild switch --flake .#mini --target-host root@minipc
    '')
  ];
}
