{
  config,
  pkgs,
  lib,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    powerManagement.enable = true;
    forceFullCompositionPipeline = true;
    prime = {
      sync.enable = true;
      offload.enable = false;
      offload.enableOffloadCmd = false;
      allowExternalGpu = true;
      nvidiaBusId = "PCI:1@0:0:0";
      # sometimes it's like this: "PCI:8@0:0:0";
      amdgpuBusId = "PCI:231@0:0:0";
    };
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia-container-toolkit.enable = true;
  environment = {
    systemPackages = with pkgs; [
      nvidia-container-toolkit
    ];
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  systemd.services.cdi-nvidia-strip-glibc = {
    description = "Copy CDI nvidia spec to /etc/cdi and strip glibc mounts";

    # Run after the toolkit CDI generator has produced the file in /run/cdi/
    after = [ "nvidia-container-toolkit-cdi-generator.service" ];
    requires = [ "nvidia-container-toolkit-cdi-generator.service" ];

    # Run on every boot so it picks up driver updates
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      set -euo pipefail

      SRC="/run/cdi/nvidia-container-toolkit.json"
      DST="/etc/cdi/nvidia-container-toolkit.json"

      # Only copy if the destination does not exist yet
      if [ -f "$DST" ]; then
        echo "$DST already exists, skipping"
        exit 0
      fi

      # Wait for the source file to appear (CDI generator may be slow)
      for i in $(seq 1 30); do
        [ -f "$SRC" ] && break
        echo "Waiting for $SRC ... ($i/30)"
        sleep 1
      done

      if [ ! -f "$SRC" ]; then
        echo "ERROR: $SRC not found after waiting, aborting"
        exit 1
      fi

      echo "Copying $SRC -> $DST and stripping glibc mounts"

      mkdir -p /etc/cdi

      # Use jq to remove any mount entry where hostPath or containerPath
      # contains the string "glibc"
      ${pkgs.jq}/bin/jq '
        .containerEditions |= map(
          .mounts |= map(
            select(
              (.hostPath      | test("glibc"; "i") | not) and
              (.containerPath | test("glibc"; "i") | not)
            )
          )
        )
      ' "$SRC" > "$DST"

      echo "Done. Glibc mounts removed from $DST"
    '';
  };

  virtualisation.containers.containersConf.settings = {
    engine = {
      cdi_spec_dirs = lib.mkForce [ "/etc/cdi" ];  # drop /var/run/cdi entirely
    };
  };
}
