{ pkgs, lib, ... }:
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


  containers = {
    kde-desktop = {
      autoStart = false;
      restartIfChanged = true;
      config = { config, pkgs, lib, ... }: {

        services.xserver.enable = true;
        services.displayManager.sddm.enable = true;
        services.displayManager.sddm.wayland.enable = true;
        services.desktopManager.plasma6.enable = true;

        environment.plasma6.excludePackages = with pkgs.kdePackages; [
          plasma-browser-integration
          konsole
          oxygen
        ];
        services.dbus.packages = with pkgs; [
          dbus
        ];

        programs.zsh.enable = true;

        users = {
          mutableUsers = true;
          users = {
            kde = {
              isNormalUser = true;
              home = "/home/kde";
              hashedPassword ="$6$2QXl.FgnDJTs.8k7$cYFROT4.EUHAWrdOovXxuyxTl9iUDYlNsCZujjYD6fGjC7lje18v9ux5tGOM.HSxeNKYI3u4ESOkdjkHfzALL0";
              description = "KDE";
              extraGroups = [ ];
	            shell = pkgs.zsh;
            };

            root = {
              home = "/root";
            };
          };
        };

        networking = {
          firewall = {
            enable = true;
            allowedTCPPorts = [ 80 ];
          };
          # Use systemd-resolved inside the container
          # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
          useHostResolvConf = lib.mkForce false;
        };

        services.resolved.enable = true;

        environment.sessionVariables = {
          DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
        };

        system.stateVersion = "24.05";
      };

      bindMounts = {
        "/run/user/1000" = {
          hostPath = "/run/user/1000";
          isReadOnly = false;
        };
        "/run/user/1000/bus" = {
          hostPath = "/run/user/1000/bus";
          isReadOnly = true;
        };
        "/tmp/.X11-unix" = {
          hostPath = "/tmp/.X11-unix";
          isReadOnly = true;
        };
        "/var/run/dbus" = {
          hostPath = "/var/run/dbus";
          isReadOnly = true;
        };
      };
    };
  };
}

