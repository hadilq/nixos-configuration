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
    platformVersions = [ "28" ];
    abiVersions = [ "x86" "x86_64"];
  };
in
{
  imports =
  [
    <home-manager/nixos>
  ];

  environment.etc = with pkgs; {
    "jdk".source = openjdk8;
    "jdk8".source = openjdk8;
    "jdk11".source = openjdk11;
    "android-sdk".source = androidComposition.androidsdk;
  };

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
    ];

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      initExtra = ''
        export ANDROID_HOME=/etc/android-sdk/libexec/android-sdk
        export ANDROID_NDK_HOME="$ANDROID_HOME/ndk-bundle"
        export NDK="$ANDROID_NDK_HOME"
        export JAVA_HOME=/etc/jdk
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
      extraConfig = {
        diff = {
          tool = "vimdiff";
          mnemonicprefix = true;
        };
        merge = {
          tool = "vimdiff";
        };
        core = {
          editor = "vim";
        };
      };
    };

    programs.firefox.enable = false;

    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [ 
        vim-flutter
        vim-flatbuffers
        vim-android
        rust-vim
        vim-ruby
      ];
      settings = { ignorecase = true; };
      extraConfig = ''
        syntax on
        filetype plugin indent on 
        " On pressing tab, insert 2 spaces
        set expandtab
        " show existing tab with 2 spaces width
        set tabstop=2
        set softtabstop=2
        " when indenting with '>', use 2 spaces width
        set shiftwidth=2
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
