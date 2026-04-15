{
  config,
  pkgs,
  lib,
  ...
}:

{
  systemd.services.sshd = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      RestartSec = "5s";
    };
  };

  # Ensure systemd waits for the network to actually be online
  systemd.services.NetworkManager-wait-online.enable = true;

  # LAN cable
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ ];
      trustedInterfaces = [ "enp2s0" ];
    };
    interfaces.enp2s0 = {
      ipv4.addresses =[
        {
          address = "192.0.2.2";
          prefixLength = 24;
        }
      ];
      useDHCP = false;  # Disable DHCP for the ethernet interface
    };
    defaultGateway = {
      address = "192.0.2.1";
      interface = "enp2s0";
    };
  };
}
