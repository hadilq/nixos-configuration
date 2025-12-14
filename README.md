# NixOS configuration

My NixOS configuration after following [this guide](https://gist.github.com/hadilq/a491ca53076f38201a8aa48a0c6afef5) to install it.

You need to adjust the `hardware-configuration.nix` file according to the generated one after running
```
nixos-generate-config --root /mnt
```
in the above guide.

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
        # hashedPassword ="*****"; # Use `mkpasswd -m sha-512` to generate it. Sometimes you need to turn the `mutableUsers` on and off to make it work!
        # to verify the hash observe that hash has $6$salt$HASH structure where you can run `mkpasswd -m sha-512 -S salt` to check the HASH

        # openssh.authorizedKeys.keys = [
        #   "ssh-rsa AAAAB3Nz....6OWM= user"
        #   # note: ssh-copy-id will add user@clientmachine after the public key
        #   # but we can remove the "@clientmachine" part
        # ];
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
  address = "192.168.2.1";
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
    # run ifconfig to find the name of your wifi interface
    interfaces.wlp0s20f3.ipv4.addresses = [{
      address = address;
      prefixLength = 28;
    }];
  };
}
```

And finally, run
```
nixos-install --flake .#darter
reboot
```
to finish the installation.

# Emergency
If you followed the above [guide](https://gist.github.com/hadilq/a491ca53076f38201a8aa48a0c6afef5) to install,
you will find below script, which is a part of script in that guide, useful.

```bash
set -euxo pipefail

DISK=/dev/nvme0n1
cryptsetup open "$DISK"p2 enc

swapon /dev/lvm/swap

# Mount the directories

mount -o subvol=root,compress=zstd,noatime /dev/lvm/root /mnt

mount -o subvol=home,compress=zstd,noatime /dev/lvm/root /mnt/home

mount -o subvol=nix,compress=zstd,noatime /dev/lvm/root /mnt/nix

mount -o subvol=persist,compress=zstd,noatime /dev/lvm/root /mnt/persist

mount -o subvol=log,compress=zstd,noatime /dev/lvm/root /mnt/var/log

# don't forget this!
mount "$DISK"p1 /mnt/boot

rm /mnt/etc/NIXOS

cd /mnt/persist/etc/nixos
nixos-install --flake .#darter
reboot
```
