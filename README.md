# NixOS configuration

My NixOS configuration after installing it like [this](https://gist.github.com/hadilq/a491ca53076f38201a8aa48a0c6afef5).

You need to add the channels first.
```
$ nix-channel --add https://nixos.org/channels/nixos-22.05 nixos
$ nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware

$ nix-channel --update
```

The `users.nix` is omitted from this repo but its content is something like
```
{ config, pkgs, ... }:

{
  users = {
    mutableUsers = true;
    users = {
      hadi = {
        isNormalUser = true;
        home = "/home/hadi";
        description = "Hadi";
        extraGroups = [ "wheel" "networkmanager" "adbusers" "libvirtd" ];
        initialHashedPassword = "";
        # hashedPassword ="*****"; // Use `mkpasswd -m sha-512` to generate it. Sometimes you need to turn the `murableUsers` on and off to make it work!
      };

      root = {
        home = "/root";
      };
    };
  };
}
```
