{ config, pkgs, ... }:

{
  imports = [ ];

  environment.systemPackages = with pkgs; [
    wget
    tree
    gnupg
    curl
    tmux
    unzip
    aspell
    aspellDicts.en
    aspellDicts.ca
    vim_configurable
    git
    openssl
    mkpasswd
    zsh
    oh-my-zsh
    screen
    firefox
    thunderbird
    vlc
    keepassx
    keepassxc
    texlive.combined.scheme-medium
    libreoffice
    gimp
    yakuake
    patchelf
    openjdk
  ];

  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.allowUnfreePredicate = (pkg: builtins.elem (pkg.pname or (builtins.parseDrvName pkg.name).name) [
  #   # unfree whitelist
  #   "idea"
  # ]);

  programs.zsh = {
    enable = true;
    histFile = "$HOME/.zsh_history";
    histSize = 2000;
  };
  programs.zsh.ohMyZsh.enable = true;

  # nixpkgs.overlays = [
  #     (final: prev: {
  #       firefox = prev.firefox.overrideAttrs (_: {
  #           postInstall = "sed -i 's/Exec=firefox %U/Exec=firefox -P --no-remote %U/' $out/share/applications/firefox.desktop";
  #         });
  #     })
  #   ];


}
