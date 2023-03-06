# NixOS configuration

My NixOS configuration after installing it like [this](https://gist.github.com/hadilq/a491ca53076f38201a8aa48a0c6afef5).

You need to add the channels first.
```
$ nix-channel --add https://nixos.org/channels/nixos-22.05 nixos
$ nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware

$ nix-channel --update
```

The `users.nix` is omitted from this repo but its content is something like
```nix
{ config, pkgs, ... }:

{
  users = {
    mutableUsers = true;
    users = {
      hadi = {
        isNormalUser = true;
        home = "/home/hadi";
        description = "Hadi";
        extraGroups = [ "wheel" "networkmanager" "adbusers" "libvirtd" "docker" ];
        initialHashedPassword = "";
        # hashedPassword ="*****"; // Use `mkpasswd -m sha-512` to generate it. Sometimes you need to turn the `mutableUsers` on and off to make it work!
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3Nz....6OWM= user"
          # note: ssh-copy-id will add user@clientmachine after the public key
          # but we can remove the "@clientmachine" part
        ];
      };

      root = {
        home = "/root";
      };
    };
  };
}
```

Also the `network.nix` is ommited too.
```nix
{ config, pkgs, ...}:
{
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = false;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
  }

  # Open ports in the firewall.
  networking.firewall = {
    allowPing = false;
    allowedTCPPorts = [];
    allowedUDPPorts = [];
  };
}
```
