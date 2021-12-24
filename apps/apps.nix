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
    xclip
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
    gdrive
    patchelf
    openjdk8
    jdk11
    jdk17
    android-studio
    androidStudioPackages.canary
    jetbrains.idea-community
    jetbrains.pycharm-community
    python38Packages.conda
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

  programs.adb.enable = true;

  programs.java = {
    enable = true;
  };

  environment.variables.ANDROID="/libexec/android-sdk";

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"
      bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"
    '';
  };
}
