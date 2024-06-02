{ pkgs, ... }:
{
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
    docker = {
      enable = true;
      storageDriver = "btrfs";
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      # dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
