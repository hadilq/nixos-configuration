{ config, pkgs, ...}:
let
  maxVMs = 5;
  lib = pkgs.lib;
in
{
  networking = {
    firewall = {
      interfaces = builtins.listToAttrs (
        map (index: {
          name = "virbr-vm${toString index}";
          value = {
            allowedTCPPorts = [ 22 80 443 2222 ];
          };
        }) (lib.genList (i: i + 1) maxVMs)
      );
      trustedInterfaces = builtins.map (index:  "virbr-vm${toString index}") (lib.genList (i: i + 1) maxVMs);
    };
  };

  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    wait-online.enable = false;
    networks = builtins.listToAttrs (
      map (index: {
        name = "virbr-vm${toString index}";
        value = {
          matchConfig.Name = "vm${toString index}";
          # Host's addresses
          address = [
            "10.0.0.0/32"
            "fec0::/128"
          ];
          # Setup routes to the VM
          routes = [ {
            Destination = "10.0.0.${toString index}/32";
          } {
            Destination = "fec0::${lib.toHexString index}/128";
          } ];
          # Enable routing
          networkConfig = {
            IPv4Forwarding = true;
            IPv6Forwarding = true;
          };
        };
      }) (lib.genList (i: i + 1) maxVMs)
    );
  };

}
