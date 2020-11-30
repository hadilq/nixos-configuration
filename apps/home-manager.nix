{ config, pkgs, ... }:

let
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    includeEmulator = true;
    includeSources = true;
    includeDocs = true;
    includeSystemImages = true;
    systemImageTypes = [ "default" ];
    includeNDK = true;
    useGoogleAPIs = true;
  };
in
{
  imports =
  [
    <home-manager/nixos>
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  # Let Home Manager install and manage itself.
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  home-manager.users.hadi = { pkgs, ... }: {
    programs.home-manager.enable = true;

    home.packages = [
      androidComposition.androidsdk
      pkgs.htop
      pkgs.nix-zsh-completions
      pkgs.android-file-transfer
      pkgs.jetbrains-mono
      pkgs.android-studio
      pkgs.androidStudioPackages.beta
      pkgs.androidStudioPackages.canary
      pkgs.jetbrains.idea-community
      pkgs.jetbrains.pycharm-community
      pkgs.python38Packages.conda
    ];

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      initExtra = ''
        export ANDROID_HOME="${androidComposition.androidsdk}/libexec/android-sdk"
        export ANDROID_NDK_HOME="$ANDROID_HOME/ndk-bundle"
        export NDK="$ANDROID_NDK_HOME"
      '';

      oh-my-zsh = {
        enable = true;
        theme = "amuse";
        plugins = [ "git" "sudo" "docker" "kubectl" ];
      };

      plugins = [
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "v0.1.0";
            sha256 = "0snhch9hfy83d4amkyxx33izvkhbwmindy0zjjk28hih1a9l2jmx";
          };
        }
      ];
    };

    programs.git = {
      enable = true;
      userName = "Hadi";
      userEmail = "hadilashkari@gmail.com";
    };

    programs.firefox.enable = false;

    programs.vim = {
      enable = true;
      settings = { ignorecase = true; };
      extraConfig = ''
        syntax on
        set clipboard=unnamedplus
        inoremap jj <Esc>
      '';
    };

    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };

    home.stateVersion = "20.09";
  };
}
