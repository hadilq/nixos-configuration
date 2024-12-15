{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    supportedFilesystems = [ "btrfs" ];
    loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        enableCryptodisk = true;
        configurationLimit = 40;
      };
    };
    initrd = {
      luks.devices = {
        root = {
          device = "/dev/disk/by-uuid/b100697a-2d7d-436b-90ac-00f71bb55a1e";
          preLVM = true;
        };
      };
    };
  };

  # Set your time zone.
  time.timeZone = "Canada/Eastern";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    options = "eng";
  };

  # virtual pdf printer backend. FYI, check /var/spool/cups-pdf-pdf/users/${USER} for the PDFs.
  services.printing.cups-pdf.enable = true;

  security = {
    # PipeWire dependency
    rtkit.enable = true;
    apparmor.enable = true;

    auditd.enable = true;
    audit.enable = true;
    audit.rules = [
      "-a exit,always -F arch=b64 -S execve"
    ];
  };

  environment.etc = {
    nixos.source = "/persist/etc/nixos";
    NIXOS.source = "/persist/etc/NIXOS";
    "NetworkManager/system-connections".source = "/persist/etc/NetworkManager/system-connections";
    "machine-id".source = "/persist/etc/machine-id";
    "resolv.conf".source = "/persist/etc/resolv.conf";
  };

  systemd.tmpfiles.rules = [
    "L /var/lib/NetworkManager/secret_key - - - - /persist/var/lib/NetworkManager/secret_key"
    "L /var/lib/NetworkManager/seen-bssids - - - - /persist/var/lib/NetworkManager/seen-bssids"
    "L /var/lib/NetworkManager/timestamps - - - - /persist/var/lib/NetworkManager/timestamps"
    "L /var/lib/docker - - - - /persist/var/lib/docker"
    "L /var/lib/libvirt - - - - /persist/var/lib/libvirt"
    "L /var/lib/nixos - - - - /persist/var/lib/nixos"
    "L /var/lib/upower - - - - /persist/var/lib/upower"
    "L /var/lib/colord - - - - /persist/var/lib/colord"
    "L /var/lib/boltd - - - - /persist/var/lib/boltd"
    "L /var/lib/AccountsService - - - - /persist/var/lib/AccountsService"
    "L /var/lib/systemd/rfkill - - - - /persist/var/lib/systemd/rfkill"
    "L /var/lib/systemd/random-seed - - - - /persist/var/lib/systemd/random-seed"
    "L /var/lib/systemd/catalog/database  - - - - /persist/var/lib/systemd/catalog/database"
    "L /var/lib/systemd/backlight - - - - /persist/var/lib/systemd/backlight"
    "L /var/lib/cosmic-greeter - - - - /persist/var/lib/cosmic-greeter"
    "L /var/db/dhcpcd - - - - /persist/var/db/dhcpcd"
    "L /root/.nix-channels - - - - /persist/root/.nix-channels"
    "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
  ];
  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

  # Note `lib.mkBefore` is used instead of `lib.mkAfter` here.
  boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
    mkdir -p /mnt

    # We first mount the btrfs root to /mnt
    # so we can manipulate btrfs subvolumes.
    mount -o subvol=/ /dev/mapper/lvm-root /mnt

    # While we're tempted to just delete /root and create
    # a new snapshot from /root-blank, /root is already
    # populated at this point with a number of subvolumes,
    # which makes `btrfs subvolume delete` fail.
    # So, we remove them first.
    #
    # /root contains subvolumes:
    # - /root/var/lib/portables
    # - /root/var/lib/machines
    #
    # I suspect these are related to systemd-nspawn, but
    # since I don't use it I'm not 100% sure.
    # Anyhow, deleting these subvolumes hasn't resulted
    # in any issues so far, except for fairly
    # benign-looking errors from systemd-tmpfiles.
    btrfs subvolume list -o /mnt/root |
    cut -f9 -d' ' |
    while read subvolume; do
      echo "deleting /$subvolume subvolume..."
      btrfs subvolume delete "/mnt/$subvolume"
    done &&
    echo "deleting /root subvolume..." &&
    btrfs subvolume delete /mnt/root

    echo "restoring blank /root subvolume..."
    btrfs subvolume snapshot /mnt/root-blank /mnt/root

    # Once we're done rolling back to a blank snapshot,
    # we can unmount /mnt and continue on the boot process.
    umount /mnt
  '';
}
