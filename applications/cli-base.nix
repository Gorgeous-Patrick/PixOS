{ pkgs, ... }:

{
  # Common Packages
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "git" "docker" ];
    };
    shellAliases = {
      ls = "eza";
      ll = "eza -l";
      lt = "eza --tree";
      la = "eza -a";
      lal = "eza -al";
      v = "nvim";
      r = "ranger";
      update = "sudo nixos-rebuild switch";
      cat = "bat";
      q = "exit";
    };
  };

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      nerdtree
      vim-airline
      gruvbox
      vim-fugitive
    ];
  };

  # Common Packages for Shell and Docker
  home.packages = with pkgs; [
    git
    neovim
    zsh
    python3
    nodejs
    docker
  ];
}

