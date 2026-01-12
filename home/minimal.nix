{ pkgs, ... }:
{
  home.username = "patrickli";
  home.homeDirectory = "/home/patrickli";
  home.stateVersion = "24.11";

  home.packages =
    import ../profiles/minimal/hm/packages.nix { inherit pkgs; };

  programs.home-manager.enable = true;
  programs.nixvim = {
    enable = true;

    clipboard.register = "unnamedplus";

    opts = {
      number = true;
      relativenumber = true;
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      smartindent = true;
      termguicolors = true;
      signcolumn = "yes";
      updatetime = 300;
    };
    plugins.telescope.enable = true;
    plugins.web-devicons.enable = true;
    plugins.nvim-tree.enable = true;
    plugins.floaterm = {
      enable = true;
    };
    plugins.gitblame.enable = true;
    plugins.lazygit.enable = true;
    plugins.auto-save.enable = true;

    ####################
    # Treesitter
    ####################
    plugins.treesitter = {
      enable = true;
      settings = {
        ensure_installed = [
          "c"
          "cpp"
          "python"
          "rust"
          "javascript"
          "typescript"
          "tsx"
          "json"
          "html"
          "css"
          "bash"
          "nix"
        ];
        indent.enable = true;
      };
    };
    ####################
    # LSP
    ####################
    plugins.lsp = {
      enable = true;

      servers = {
        # Frontend
        ts_ls.enable = true;
        html.enable = true;
        cssls.enable = true;
        jsonls.enable = true;

        # Python
        pyright.enable = true;

        # Rust
        rust_analyzer.enable = true;
        rust_analyzer.installRustc = false;
        rust_analyzer.installCargo = false;

        # C / C++
        clangd.enable = true;
      };
    };

    keymaps = [
      {
        mode = [ "i" "v" "s" "o" "t" ];
        key = "jk";
        action = "<Esc>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = ["n"];
        key = "<C-n>";
        action = "<cmd>NvimTreeToggle<CR>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = ["n"];
        key = "H";
        action = "^";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = ["n"];
        key = "L";
        action = "$";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = ["n" "t"];
        key = "<leader>tt";
        action = "<cmd>FloatermToggle<CR>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = ["t"];
        key = "<esc>";
        action = "<C-\\><C-n>";
        options = {
          noremap = true;
          silent = true;
        };
      }


    ];

  };

  programs.git = {
    enable = true;
    userName = "Patrick Li";
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
  };
}
