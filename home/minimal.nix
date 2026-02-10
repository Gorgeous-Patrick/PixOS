{ pkgs, ... }:
{
  home.username = "patrickli";
  home.homeDirectory = "/home/patrickli";
  home.stateVersion = "25.11";

  home.packages = import ../profiles/minimal/hm/packages.nix { inherit pkgs; };

  programs.home-manager.enable = true;
  programs.gh.enable = true;

  services.syncthing = {
    enable = true;
    settings = {
      devices = {
        "vultr" = {
          id = "UQSOBLO-VSYHIY3-4JVNHYF-UPNIMZ3-ET7G5TB-DCUEWCB-IGTM7DC-DWE7VAM";
        };
      };
    };
  };

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
    plugins.autoclose.enable = true;

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
    ####################
    # Completion
    ####################
    plugins.cmp = {
      enable = true;
      autoEnableSources = true;

      settings = {
        mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = "cmp.mapping.select_next_item()";
          "<S-Tab>" = "cmp.mapping.select_prev_item()";
        };

        sources = [
          { name = "nvim_lsp"; }
          { name = "buffer"; }
          { name = "path"; }
        ];
      };
    };

    ####################
    # Vibe Coding
    ####################
    plugins.snacks = {
      enable = true;
      settings = {
        input = { };
        picker = { };
        terminal = { };
      };
    };
    plugins.opencode = {
      enable = true;
    };

    keymaps = [
      {
        mode = [
          "i"
          "v"
          "s"
          "o"
          "t"
        ];
        key = "jk";
        action = "<Esc>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = [ "n" ];
        key = "<C-n>";
        action = "<cmd>NvimTreeToggle<CR>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = [ "n" ];
        key = "H";
        action = "^";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = [ "n" ];
        key = "L";
        action = "$";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = [
          "n"
          "t"
        ];
        key = "<leader>tt";
        action = "<cmd>FloatermToggle<CR>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = [ "t" ];
        key = "<esc>";
        action = "<C-\\><C-n>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = [
          "n"
          "t"
        ];
        key = "<leader>gg";
        action = "<cmd>LazyGit<CR>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        key = "<C-a>";
        mode = [
          "n"
          "x"
        ];
        action = ''
          function()
            require("opencode").ask("@this: ", { submit = true })
          end
        '';
        options.desc = "Ask opencode…";
      }

      {
        key = "<C-x>";
        mode = [
          "n"
          "x"
        ];
        action = ''
          function()
            require("opencode").select()
          end
        '';
        options.desc = "Execute opencode action…";
      }

      {
        key = "<C-.>";
        mode = [
          "n"
          "t"
        ];
        action = ''
          function()
            require("opencode").toggle()
          end
        '';
        options.desc = "Toggle opencode";
      }

      {
        key = "go";
        mode = [
          "n"
          "x"
        ];
        action = ''
          function()
            return require("opencode").operator("@this ")
          end
        '';
        options = {
          desc = "Add range to opencode";
          expr = true;
        };
      }

      {
        key = "goo";
        mode = [ "n" ];
        action = ''
          function()
            return require("opencode").operator("@this ") .. "_"
          end
        '';
        options = {
          desc = "Add line to opencode";
          expr = true;
        };
      }

      {
        key = "<S-C-u>";
        mode = [ "n" ];
        action = ''
          function()
            require("opencode").command("session.half.page.up")
          end
        '';
        options.desc = "Scroll opencode up";
      }

      {
        key = "<S-C-d>";
        mode = [ "n" ];
        action = ''
          function()
            require("opencode").command("session.half.page.down")
          end
        '';
        options.desc = "Scroll opencode down";
      }

      {
        key = "+";
        mode = [ "n" ];
        action = "<C-a>";
        options = {
          desc = "Increment under cursor";
          noremap = true;
        };
      }

      {
        key = "-";
        mode = [ "n" ];
        action = "<C-x>";
        options = {
          desc = "Decrement under cursor";
          noremap = true;
        };
      }
    ];

  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Patrick Li";
      user.email = "baichuanli@yahoo.com";
    };
  };

  programs.opencode.enable = true;

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
      g = "lazygit";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };
}
