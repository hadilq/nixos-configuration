{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  hardware.system76.kernel-modules.enable = true;
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    supportedFilesystems = [ "btrfs" ];
    loader = {
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
      availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "sdhci_pci" ];
      kernelModules = [ "dm-snapshot" ];
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

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable the GNOME Desktop Environment.
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    displayManager.defaultSession = "gnome";
  };

  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    xterm
  ]) ++ (with pkgs.gnome; [
    cheese # webcam tool
    gnome-music
    gnome-terminal
    gedit # text editor
    epiphany # web browser
    geary # email reader
    evince # document viewer
    gnome-characters
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
    yelp # Help view
    gnome-contacts
  ]);

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbOptions = "eng";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver = {
    libinput.enable = true;
    libinput.touchpad.naturalScrolling = true;
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  security.rtkit.enable = true;
  security.apparmor.enable = true;

  security.auditd.enable = true;
  security.audit.enable = true;
  security.audit.rules = [
    "-a exit,always -F arch=b64 -S execve"
  ];

  environment.etc = {
    nixos.source = "/persist/etc/nixos";
    NIXOS.source = "/persist/etc/NIXOS";
    "NetworkManager/system-connections".source = "/persist/etc/NetworkManager/system-connections";
  };

  systemd.tmpfiles.rules = [
    "L /var/lib/NetworkManager/secret_key - - - - /persist/var/lib/NetworkManager/secret_key"
    "L /var/lib/NetworkManager/seen-bssids - - - - /persist/var/lib/NetworkManager/seen-bssids"
    "L /var/lib/NetworkManager/timestamps - - - - /persist/var/lib/NetworkManager/timestamps"
    "L /var/lib/docker - - - - /persist/var/lib/docker"
    "L /var/lib/libvirt - - - - /persist/var/lib/libvirt"
    "L /var/lib/nixos - - - - /persist/var/lib/nixos"
    "L /var/lib/upower - - - - /persist/var/lib/upower"
    # "L /var/lib/colord - - - - /persist/var/lib/colord"
    "L /var/lib/boltd - - - - /persist/var/lib/boltd"
    "L /var/lib/AccountsService - - - - /persist/var/lib/AccountsService"
    "L /var/lib/systemd/rfkill - - - - /persist/var/lib/rfkill"
    "L /var/lib/systemd/random-seed - - - - /persist/var/lib/random-seed"
    "L /var/db/dhcpcd - - - - /persist/var/db/dhcpcd"
    "L /root/.nix-channels - - - - /persist/root/.nix-channels"
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
