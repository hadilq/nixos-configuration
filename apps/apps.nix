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
    signaldctl
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

  # Signal
  services.signald = {
    enable = true;
    user = "hadi";
  };
}
