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
    vimPlugins.vim-flutter
    vimPlugins.vim-flatbuffers
    vimPlugins.vim-android
    vimPlugins.rust-vim
    vimPlugins.vim-ruby
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
    rclone
    patchelf
    openjdk8
    openjdk11
    android-studio
    androidStudioPackages.beta
    androidStudioPackages.canary
    jetbrains.idea-community
    jetbrains.pycharm-community
    python38Packages.conda
    flutterPackages.beta
    flutter
    clang
    rustc
    rustfmt
    rustPackages.clippy
    cargo
    cargo-make
    flatbuffers
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.android_sdk.accept_license = true;

  programs.zsh = {
    enable = true;
    histFile = "$HOME/.zsh_history";
    histSize = 2000;
  };
  programs.zsh.ohMyZsh.enable = true;

  programs.screen.screenrc = ''
    defscrollback 5000
  '';

  programs.adb.enable = true;

  programs.java = {
    enable = true;
  };

  environment.variables.ANDROID="/libexec/android-sdk";
}
