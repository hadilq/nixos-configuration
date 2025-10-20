{ config, lib, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    kernelParams = [ "quiet" ];
    plymouth.enable = true;
    supportedFilesystems = [ "btrfs" ];
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        configurationLimit = 40;
      };
    };
    initrd = {
      luks.devices = {
        root = {
          device = "/dev/disk/by-uuid/b100697a-2d7d-436b-90ac-00f71bb55a1e";
        };
      };
    };
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/dadcb08f-19d0-4c82-96ea-73962fa1f2de";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" "noatime" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/dadcb08f-19d0-4c82-96ea-73962fa1f2de";
      fsType = "btrfs";
      options = [ "subvol=home" "compress=zstd" "noatime" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/dadcb08f-19d0-4c82-96ea-73962fa1f2de";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" ];
    };

  fileSystems."/persist" =
    { device = "/dev/disk/by-uuid/dadcb08f-19d0-4c82-96ea-73962fa1f2de";
      fsType = "btrfs";
      options = [ "subvol=persist" "compress=zstd" "noatime" ];
      neededForBoot = true;
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/dadcb08f-19d0-4c82-96ea-73962fa1f2de";
      fsType = "btrfs";
      options = [ "subvol=log" "compress=zstd" "noatime" ];
      neededForBoot = true;
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/3C6D-3824";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/61c80561-8301-4952-b124-278544929d02"; }
    ];

  hardware.system76.enableAll = true;
  hardware.system76.kernel-modules.enable = true;

  networking.hostName = "darter"; # Define your hostname.
  networking.networkmanager.enable = true;

  networking.interfaces.enp36s0.useDHCP = lib.mkDefault true;
  networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
