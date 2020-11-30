{ config, pkgs, ... }:

{
  imports = [ ];

  services.openvpn.servers = {
    officeVPN  = { config = '' config /home/hadi/wspace/ifood/client.ovpn ''; };
  };

}
