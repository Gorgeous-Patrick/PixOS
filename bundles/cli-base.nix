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
    pkgs.lazygit
    pkgs.bat
    pkgs.nixfmt-rfc-style
    pkgs.treefmt
    pkgs.eza
    pkgs.htop
    pkgs.devenv
    pkgs.neofetch
    pkgs.tmux
    pkgs.sl
    pkgs.tg
    pkgs.cloc
    pkgs.cryfs
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
      dataon = "cryfs ~/Space/PixOS/Safe_Encrypted/ ~/Safe/";
      dataoff = "cryfs-unmount ~/Safe/";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
      ];
      theme = "robbyrussell";
    };
  };
}
