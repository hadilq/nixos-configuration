{ config, pkgs, lib, ... }:

{
  #boot.kernelParams = [
  #  "pci=assign-busses"        # reassign bus numbers cleanly
  #  # to increase PCIe memory window allocation
  #  "pci=realloc,realloc_size=512M"
  #  "pcie_aspm=off"
  #  "pcie_port_pm=off"
  #];
  nixpkgs.config.allowUnfree = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    prime = {
      #sync.enable = true;
      #offload = {
      #  enable = false;
      #  enableOffloadCmd = false;
      #};
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      allowExternalGpu = true;
      nvidiaBusId = "PCI:0:6:2";
      intelBusId = "PCI:0:2:0";
    };
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  #environment.sessionVariables = {
  #  # nvidia-offload see https://nixos.wiki/wiki/Nvidia#offload_mode
  #  __NV_PRIME_RENDER_OFFLOAD = "1";
  #  __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
  #  __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  #  __VK_LAYER_NV_optimus = "NVIDIA_only";
  #};
  services.hardware.bolt.enable = true;
  services.thermald.enable = true;
  environment.systemPackages = with pkgs; [
    pciutils
  ];
  #systemd.services.pcie-rescan = {
  #  description = "Rescan PCIe bus for eGPU";
  #  wantedBy = [ "multi-user.target" ];
  #  after = [ "systemd-udev-settle.service" ];
  #  serviceConfig = {
  #    Type = "oneshot";
  #    ExecStartPre = "/bin/sh -c 'sleep 5'";  # wait for dock to fully power on
  #    ExecStart = "/bin/sh -c 'echo 1 > /sys/bus/pci/rescan'";
  #    RemainAfterExit = true;
  #  };
  #};
}
