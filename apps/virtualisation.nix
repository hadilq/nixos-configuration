{
  virtualisation = {
    virtualbox.host.enable = true;
    libvirtd.enable = true;
    docker = {
      enable = true;
      storageDriver = "btrfs";
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    #lxd = {
    #  enable = true;
    #  recommendedSysctlSettings = true;
    #};
  };
}
