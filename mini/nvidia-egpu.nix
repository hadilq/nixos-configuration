{
  config,
  pkgs,
  lib,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    powerManagement.enable = true;
    forceFullCompositionPipeline = true;
    prime = {
      sync.enable = true;
      offload.enable = false;
      offload.enableOffloadCmd = false;
      allowExternalGpu = true;
      nvidiaBusId = "PCI:1@0:0:0";
      # sometimes it's like this: "PCI:8@0:0:0";
      amdgpuBusId = "PCI:231@0:0:0";
    };
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia-container-toolkit.enable = true;
  environment.etc."cdi/nvidia-container-toolkit.json".source = "/run/cdi/nvidia-container-toolkit.json";
}
