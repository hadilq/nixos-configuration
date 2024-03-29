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
    bat
    file
    xclip
    vim_configurable
    git
    openssl
    mkpasswd
    zsh
    oh-my-zsh
    clang
    gnome.gnome-tweaks
  ];

  # GNOME Desktop dconf
  programs.dconf.enable = true;

  programs.adb.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "curses";
  };

  programs.zsh = {
    enable = true;
    histFile = "$HOME/.zsh_history";
    histSize = 2000;
  };

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
