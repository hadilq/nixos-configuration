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
}
