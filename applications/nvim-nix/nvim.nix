{ config, pkgs, lib, ... }:

let
nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
    # If you are not running an unstable channel of nixpkgs, select the corresponding branch of nixvim.
    ref = "nixos-24.11";
  });

in
{
imports = [
    # For home-manager
    nixvim.homeManagerModules.nixvim
    # For NixOS
    # nixvim.nixosModules.nixvim
    # For nix-darwin
    # nixvim.nixDarwinModules.nixvim
  ];

  # Install Neovim and related tools
  programs.nixvim = {
    enable = true;
    # colorschemes.catppuccin.enable = true;
    plugins.lualine.enable = true;
    plugins.lazygit.enable = true;
    plugins.nvim-tree = {
      enable = true;
    };
    plugins.trouble.enable = true;
    plugins.web-devicons.enable = true;
    plugins.treesitter.enable = true;
    plugins.cmp = {
      enable = true;
      autoEnableSources = true;
      settings.sources = [
	{ name = "nvim_lsp"; }
	{ name = "path"; }
	{ name = "buffer"; }
      ];
    };
    plugins.toggleterm.enable = true;
    plugins.todo-comments.enable = true;
    opts = {
      number = true;         # Show line numbers
      relativenumber = true; # Show relative line numbers

      shiftwidth = 2;        # Tab width should be 2
    };


    # Add Neovim plugins
    extraPlugins = with pkgs.vimPlugins; [
      telescope-nvim

      nvim-lspconfig
      lsp-zero-nvim
      lazy-lsp-nvim
      auto-save-nvim
      nvim-autopairs
    ];

    # Additional Neovim settings
    # extraConfig = ''
    #   set number
    #   set relativenumber
    #   syntax enable
    #   colorscheme catppuccin
    #   set clipboard=unnamedplus
    # '';

    extraConfigLua = (builtins.readFile ./init.lua);
  };


  # # Link custom init.lua
  # home.file.".config/nvim/init.lua".source = ./nvim/init.lua;

  # Set environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
  };
}

