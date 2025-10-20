{ config, lib, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/hardware/network/broadcom-43xx.nix")
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
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
      availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];
      luks.devices = {
        root = {
          device = "/dev/disk/by-uuid/b144559d-15b6-4399-bc2b-adf43a3ab5f1";
        };
      };
    };
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/a665129d-4ca4-4aad-8032-cbb2e40071da";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/a665129d-4ca4-4aad-8032-cbb2e40071da";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/a665129d-4ca4-4aad-8032-cbb2e40071da";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/persist" =
    { device = "/dev/disk/by-uuid/a665129d-4ca4-4aad-8032-cbb2e40071da";
      fsType = "btrfs";
      options = [ "subvol=persist" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/a665129d-4ca4-4aad-8032-cbb2e40071da";
      fsType = "btrfs";
      options = [ "subvol=log" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/FA0A-5C49";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/f79960df-1e31-4d44-9fa2-5d5db8aed160"; }
    ];

  networking.hostName = "macy"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  networking.interfaces.wlp3s0.useDHCP = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

