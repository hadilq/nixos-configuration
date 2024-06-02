{ lib, pkgs, ... }:
{
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
