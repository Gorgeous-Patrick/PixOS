 {
  description = "Nix Flake for Neovim configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, nixvim, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        # Home Manager module
        homeManagerModules.nixvim = nixvim.homeManagerModules.nixvim;

        # Development environment
        devShell = pkgs.mkShell {
          buildInputs = [ pkgs.neovim pkgs.git ];
        };

        # Home Manager configuration
        homeConfigurations.patrickli = pkgs.lib.mkIf pkgs.stdenv.isLinux {
          imports = [ nixvim.homeManagerModules.nixvim ];

          programs.nixvim = {
            enable = true;
            colorschemes.nightfox.enable = true;
            plugins = {
              lualine.enable = true;
              lazygit.enable = true;
              nvim-tree.enable = true;
              trouble.enable = true;
              web-devicons.enable = true;
              treesitter.enable = true;
              cmp = {
                enable = true;
                autoEnableSources = true;
                settings.sources = [
                  { name = "nvim_lsp"; }
                  { name = "path"; }
                  { name = "buffer"; }
                ];
              };
              toggleterm.enable = true;
              todo-comments.enable = true;
              which-key.enable = true;
            };

            opts = {
              number = true;
              relativenumber = true;
              shiftwidth = 2;
            };

            extraPlugins = with pkgs.vimPlugins; [
              telescope-nvim
              nvim-lspconfig
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
            ];

            extraConfigLua = builtins.readFile ./init.lua;
          };

          home.sessionVariables = {
            EDITOR = "nvim";
          };
        };
      });
}

