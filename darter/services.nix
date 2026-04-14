{
  config,
  pkgs,
  lib,
  ...
}:

{
  # LAN cable
  networking = {
    interfaces.enp12s0 = {
      ipv4.addresses =[
        {
          address = "192.0.2.3";
          prefixLength = 24;
        }
      ];
      useDHCP = false;  # Disable DHCP for the ethernet interface
    };
  };
}
