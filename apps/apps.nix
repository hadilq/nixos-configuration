{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    tree
    gnupg
    curl
    unzip
    bat
    file
    xclip
    vim
    openssl
    mkpasswd
    clang
    # Not needed when virtualisation.docker.enable = true;
    docker-client
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-tty;
  };

  programs.zsh = {
    enable = true;
    histFile = "$HOME/.zsh_history";
    histSize = 2000;
  };

  programs.git = {
    enable = true;
  };
}
