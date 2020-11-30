{
  virtualisation = {
    docker.enable = true;
    # virtualbox is broken for now!
    # virtualbox.host.enable = true;
    lxd = {
      enable = true;
      recommendedSysctlSettings = true;
    };
  };
}
