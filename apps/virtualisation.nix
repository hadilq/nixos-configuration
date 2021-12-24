{
  virtualisation = {
    docker.enable = true;
    virtualbox.host.enable = true;
    lxd = {
      enable = true;
      recommendedSysctlSettings = true;
    };
  };
}
