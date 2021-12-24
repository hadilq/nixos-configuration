# NixOS configuration

My NixOS configuration after installing it like [this](https://gist.github.com/hadilq/a491ca53076f38201a8aa48a0c6afef5).

The `users.nix` is omitted from this repo but its content is something like
```
{ config, pkgs, ... }:

{
  users = {
    ....
    users = {
      hadi = {
        ...
      };

      root = {
        ...
      };
    };
  };
}

```
