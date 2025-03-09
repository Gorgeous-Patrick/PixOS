{ config, pkgs, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # The home.stateVersion option does not have a default and must be set
  home.stateVersion = "24.11";
  # Here goes the rest of your home-manager config, e.g. home.packages = [ pkgs.foo ];
  home.packages = [
    pkgs.ranger
    pkgs.thefuck
    pkgs.lazygit
    pkgs.bat
    pkgs.nixfmt-rfc-style
    pkgs.treefmt2
    pkgs.eza
    pkgs.htop
    pkgs.devenv
    pkgs.neofetch
    pkgs.tmux
    pkgs.sl
  ];
  programs.git = {
    enable = true;
    userName = "Gorgeous-Patrick";
    userEmail = "baichuanli@yahoo.com";
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtraFirst = ''
      echo Welcome to PixOS! 🚀
    '';
    shellAliases = {
      ls = "eza";
      ll = "ls -l";
      lt = "ls --tree";
      la = "ls -a";
      lal = "ls -al";
      v = "nvim";
      r = "ranger";
      cat = "bat";
      q = "exit";
      c = "clear";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "thefuck"
      ];
      theme = "robbyrussell";
    };
  };
}
