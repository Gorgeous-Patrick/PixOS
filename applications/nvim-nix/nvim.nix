{ config, pkgs, ... }:

{
  # Enable Home Manager
  programs.home-manager.enable = true;

  # Install Neovim and related tools
  programs.neovim = {
    enable = true;

    # Add Neovim plugins
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter
      telescope-nvim
      gruvbox
      vim-airline
      nerdtree
    ];

    # Additional Neovim settings
    extraConfig = ''
      set number
      set relativenumber
      syntax enable
      colorscheme gruvbox
      set clipboard=unnamedplus
    '';
  };

  # Install other useful tools
  home.packages = with pkgs; [
    ripgrep
    fd
    tree-sitter
    git
  ];

  # Link custom init.lua
  home.file.".config/nvim/init.lua".source = ./nvim/init.lua;

  # Set environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Specify Home Manager version
  home.stateVersion = "23.11";
}

