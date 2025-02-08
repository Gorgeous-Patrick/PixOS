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
    colorschemes.nightfox.enable = true;
    plugins.lualine.enable = true;
    plugins.lazygit.enable = true;
    plugins.obsidian.enable = true;
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
      settings.mapping = {
        "<C-Space>" = "cmp.mapping.complete()";
        "<C-d>" = "cmp.mapping.scroll_docs(-4)";
        "<C-e>" = "cmp.mapping.close()";
        "<C-f>" = "cmp.mapping.scroll_docs(4)";
        "<CR>" = "cmp.mapping.confirm({ select = true })";
        "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
        "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
      };
    };
    plugins.toggleterm.enable = true;
    plugins.todo-comments.enable = true;
    plugins.which-key.enable = true;
    opts = {
      number = true;         # Show line numbers
      relativenumber = true; # Show relative line numbers
      shiftwidth = 2;        # Tab width should be 2
      expandtab = true;
    };


    # Add Neovim plugins
    extraPlugins = with pkgs.vimPlugins; [
      telescope-nvim

      nvim-lspconfig
      # lsp-zero-nvim
      lazy-lsp-nvim
      auto-save-nvim
      nvim-autopairs
    ];

    keymaps = [
      {
        action = "<Esc>";
        key = "jk";
        mode = ["i"];
      }
      {
        action = "<cmd>NvimTreeToggle<CR>";
        key = "<C-n>";
        mode = ["n" "v"];
        options = {
          desc = "Toggle Tree View.";
        };
      }
      {
        action = "^";
        key = "<S-h>";
        mode = ["n" "v"];
      }
      {
        action = "$";
        key = "<S-l>";
        mode = ["n" "v"];
      }
      {
        action = "<cmd>ToggleTerm direction=float<CR>";
        key = "<C-CR>";
        mode = ["n" "t"];
        options = {
          desc = "Toggle terminal";
        };
      }
      {
        action = "<cmd>Telescope find_files<cr>";
        key = "<leader>ff";
        mode = ["n" "t"];
        options = {
          desc = "Find Files";
        };
      }
      {
        action = "<cmd>LazyGit<cr>";
        key = "<leader>gg";
        mode = ["n" "t" "v"];
        options = {
          desc = "Git";
        };
      }
      {
        action = "<cmd>Trouble diagnostics toggle<cr>";
        key = "<leader>tt";
        mode = ["n" "v"];
        options = {
          desc = "Toggle Trouble";
        };
      }
      {
	  action = "<cmd>Telescope find_files<cr>";
	  key = "<leader>ff";
	  mode = ["n" "v" "t"];
	  options = {
	    desc = "Find Files";
	  };
	}
	{
	  action = "<cmd>Telescope live_grep<cr>";
	  key = "<leader>fg";
	  mode = ["n" "v" "t"];
	  options = {
	    desc = "Live Grep";
	  };
	}
	{
	  action = "<cmd>Telescope buffers<cr>";
	  key = "<leader>fb";
	  mode = ["n" "v" "t"];
	  options = {
	    desc = "Buffers";
	  };
	}
	{
	  action = "<cmd>Telescope help_tags<cr>";
	  key = "<leader>fh";
	  mode = ["n" "v" "t"];
	  options = {
	    desc = "Help Tags";
	  };
	}

    ];

    extraConfigLua = (builtins.readFile ./init.lua);
  };


  # # Link custom init.lua
  # home.file.".config/nvim/init.lua".source = ./nvim/init.lua;

  # Set environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
  };
}

