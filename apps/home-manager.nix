{ config, pkgs, ... }:

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
      pkgs.htop pkgs.nix-zsh-completions
    ];

    programs.zsh = {
      enable = true;

      oh-my-zsh = {
        enable = true;
        theme = "amuse";
        plugins = [ "git" "sudo" "docker" "kubectl" ];
      };
    };

    programs.git = {
      enable = false;
      userName = "Hadi";
      userEmail = "hadilashkari@gmail.com";
    };

    programs.firefox.enable = false;
    # programs.firefox = {
    #   enable = true;
    #   extensions =
    #   with pkgs.nur.repos.rycee.firefox-addons; [
    #     tab-center-redux
    #   ];
    #   profiles = {
    #     Default = {
    #       id = 0;
    #       settings = {
    #         "general.smoothScroll" = false;
    #       };
    #     };
    #   };
    # };

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
