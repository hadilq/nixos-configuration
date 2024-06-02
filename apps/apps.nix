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
    git
    openssl
    mkpasswd
    clang
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.gcr;
  };

  programs.zsh = {
    enable = true;
    histFile = "$HOME/.zsh_history";
    histSize = 2000;
  };
}
