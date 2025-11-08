{ pkgs, ... }:
{
  # This is a fork of https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html
  # Also check https://gist.github.com/hadilq/a491ca53076f38201a8aa48a0c6afef5
  #
  # Darling Erasure
  # 
  # Now that we’re comfortable in our desktop environment of choice (mine is XMonad), we can move onto the opt-in state setup. First, we need to find out what state exists in the first place. Seeing what has changed since we took the blank snapshot seems like a good way to do this.
  # 
  # Taking a diff between the root subvolume and the root-blank subvolume (in btrfs, snapshots are just subvolumes) can be done with a script based off of the answers to
  # 
  # ```
  # sudo mkdir /mnt
  # sudo mount -o subvol=/ /dev/mapper/lvm-root /mnt
  # ./fs-diff.sh
  # ```
  # 
  # This may show a surprisingly small list of files, or possible something fairly lengthy, depending on your configuration. We’ll first tackle NetworkManager, so we don’t have to re-type passwords to Wi-Fi access points after every reboot. While grahamc’s original blog post suggests that simply persisting /etc/NetworkManager/system-connections by moving it to somewhere in /persist and creating a symlink is enough, this was not enough to get it to work on my XMonad setup. I ended up with something like this, symlinking a few files in /var/lib/NetworkManager as well.
  # 
  # ```
  #  environment.etc = {
  #     "NetworkManager/system-connections".source = "/persist/etc/NetworkManager/system-connections";
  #   };
  #   systemd.tmpfiles.rules = [
  #     "L /var/lib/NetworkManager/secret_key - - - - /persist/var/lib/NetworkManager/secret_key"
  #     "L /var/lib/NetworkManager/seen-bssids - - - - /persist/var/lib/NetworkManager/seen-bssids"
  #     "L /var/lib/NetworkManager/timestamps - - - - /persist/var/lib/NetworkManager/timestamps"
  #   ];
  # ```
  # 
  # Rolling back the root subvolume is a little bit involved when compared to zfs, but can be achieved with this config.
  # 
  # ```
  # # Note `lib.mkBefore` is used instead of `lib.mkAfter` here.
  #   boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
  #     mkdir -p /mnt
  # 
  #     # We first mount the btrfs root to /mnt
  #     # so we can manipulate btrfs subvolumes.
  #     mount -o subvol=/ /dev/mapper/enc /mnt
  # 
  #     # While we're tempted to just delete /root and create
  #     # a new snapshot from /root-blank, /root is already
  #     # populated at this point with a number of subvolumes,
  #     # which makes `btrfs subvolume delete` fail.
  #     # So, we remove them first.
  #     #
  #     # /root contains subvolumes:
  #     # - /root/var/lib/portables
  #     # - /root/var/lib/machines
  #     #
  #     # I suspect these are related to systemd-nspawn, but
  #     # since I don't use it I'm not 100% sure.
  #     # Anyhow, deleting these subvolumes hasn't resulted
  #     # in any issues so far, except for fairly
  #     # benign-looking errors from systemd-tmpfiles.
  #     btrfs subvolume list -o /mnt/root |
  #     cut -f9 -d' ' |
  #     while read subvolume; do
  #       echo "deleting /$subvolume subvolume..."
  #       btrfs subvolume delete "/mnt/$subvolume"
  #     done &&
  #     echo "deleting /root subvolume..." &&
  #     btrfs subvolume delete /mnt/root
  # 
  #     echo "restoring blank /root subvolume..."
  #     btrfs subvolume snapshot /mnt/root-blank /mnt/root
  # 
  #     # Once we're done rolling back to a blank snapshot,
  #     # we can unmount /mnt and continue on the boot process.
  #     umount /mnt
  #   '';
  #   ```
  #   While NixOS will take care of creating the specified symlinks, we need to move the relevant file and directories to where the symlinks are pointing at after running sudo nixos-rebuild boot and before rebooting.
  # 
  #   ```
  #   sudo nixos-rebuild boot
  # 
  # sudo mkdir -p /persist/etc/NetworkManager
  # sudo cp -r {,/persist}/etc/NetworkManager/system-connections
  # sudo mkdir -p /persist/var/lib/NetworkManager
  # sudo cp /var/lib/NetworkManager/{secret_key,seen-bssids,timestamps} /persist/var/lib/NetworkManager/
  # 
  # sudo cp {,/persist}/etc/nixos
  # sudo cp {,/persist}/etc/adjtime
  # sudo cp {,/persist}/etc/NIXOS
  # ```
  # Before rebooting, make sure that your user credentials are appropriately handled. Be especially careful4 when setting users.mutableUsers to false and using users.extraUsers.<name?>.passwordFile, as these settings are some of the few in NixOS which can lock you out across NixOS configurations and require non-trivial recovery work or a reinstall. If you want declerative user management, I recommend using users.extraUsers.<name?>.hashedPasswords, but this has it’s own downsides as well.5
  # 
  # Take another deep breath.
  # 
  # ```
  # reboot
  # ```

  environment.systemPackages = [
  (pkgs.writeShellScriptBin "btrfs-diff" ''
     set -euo pipefail
     
     OLD_TRANSID=$(sudo btrfs subvolume find-new /mnt/root-blank 9999999)
     OLD_TRANSID=''${OLD_TRANSID#transid marker was }
     
     sudo btrfs subvolume find-new "/mnt/root" "$OLD_TRANSID" |
     sed '$d' |
     cut -f17- -d' ' |
     sort |
     uniq |
     while read path; do
       path="/$path"
       if [ -L "$path" ]; then
         : # The path is a symbolic link, so is probably handled by NixOS already
       elif [ -d "$path" ]; then
         : # The path is a directory, ignore
       else
         echo "$path"
       fi
     done
    '')
  ];
}
