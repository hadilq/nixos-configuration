{ lib, pkgs, ... }:
{
  imports = [
    <nixos-hardware/common/pc>
    <nixos-hardware/common/pc/laptop>
    <nixos-hardware/common/pc/laptop/ssd>
  ];

  hardware.bluetooth.enable = true;
  hardware.system76.enableAll = lib.mkDefault true;

  # Enable sound
  # Enable Pipewire
  hardware.pulseaudio.enable = false;
  services.pipewire = {
     enable = true;
     alsa.enable = true;
     alsa.support32Bit = true;
     pulse.enable = true;
  };
}
