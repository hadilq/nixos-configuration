# NixOS configuration

My NixOS configuration after installing it like [this](https://gist.github.com/hadilq/f12f5378b74f1bdd440144373dfc5687).

You need to add the channels first.
```
$ nix-channel --add https://nixos.org/channels/nixos-23.05 nixos
$ nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware

$ nix-channel --update
```

The `users.nix` is omitted from this repo but its content is something like
```nix
{ config, pkgs, ... }:
let
  serviceConfig = {
    MountAPIVFS = true;
    PrivateTmp = true;
    PrivateUsers = true;
    ProtectKernelModules = true;
    PrivateDevices = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectKernelTunables = true;
    ProtectSystem = "full";
    RestrictSUIDSGID = true;
  };
in
{
  users = {
    mutableUsers = true;
    users = {
      hadi = {
        isNormalUser = true;
        uid = 1000;
        subUidRanges = [
          { startUid = 100000; count = 65536; }
        ];
        subGidRanges = [
          { startGid = 100000; count = 65536; }
        ];
        group = "hadi";
        home = "/home/hadi";
        description = "Hadi";
        extraGroups = [ "wheel" "networkmanager" "adbusers" "libvirtd" "podman" "kvm" "qemu-libvirtd" "video" ];
        initialHashedPassword = "";
        # hashedPassword ="*****"; // Use `mkpasswd -m sha-512` to generate it. Sometimes you need to turn the `mutableUsers` on and off to make it work!
        # to verify the hash observe that hash has $6$salt$HASH structure where you can run `mkpasswd -m sha-512 -S salt` to check the HASH
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3Nz....6OWM= user"
          # note: ssh-copy-id will add user@clientmachine after the public key
          # but we can remove the "@clientmachine" part
        ];
        shell = pkgs.zsh;
      };

      root = {
        home = "/root";
      };
    };

    groups = {
      hadi = {
        gid = 1000;
      };
    };
  };

  systemd.services.hadi.serviceConfig = serviceConfig;
  systemd.services.root.serviceConfig = serviceConfig;
}
```

Also the `network.nix` is ommited too.
```nix
{ config, pkgs, ...}:
let
  address = "192.168.1.1";
  port = 123;
in
{
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
    listenAddresses = [
      {
        addr = address;
        port = port;
      }
    ];
  };

  networking = {
    firewall = {
      allowPing = false;
      allowedTCPPorts = [];
      allowedUDPPorts = [];
    };
    interfaces.wlp0s20f3.ipv4.addresses = [{
      address = address;
      prefixLength = 28;
    }];
  };
}
```
