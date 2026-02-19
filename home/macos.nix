{ pkgs, config, lib, ... }:
{
  home.username = "patrickli";
  home.homeDirectory = lib.mkForce "/Users/patrickli";
  home.stateVersion = "25.11";

  home.packages = import ../profiles/macos/hm/packages.nix { inherit pkgs; };

  programs.home-manager.enable = true;
  programs.gh.enable = true;

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
    plugins.floaterm.enable = true;
    plugins.gitblame.enable = true;
    plugins.lazygit.enable = true;
    plugins.auto-save.enable = true;
    plugins.autoclose.enable = true;

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

    plugins.lsp = {
      enable = true;
      servers = {
        ts_ls.enable = true;
        nil_ls.enable = true;
        pyright.enable = true;
        rust_analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
        };
      };
    };

    plugins.cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
        mapping = {
          "<Tab>" = "cmp.mapping.select_next_item()";
          "<S-Tab>" = "cmp.mapping.select_prev_item()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
        };
      };
    };

    colorschemes.catppuccin = {
      enable = true;
      settings.flavour = "mocha";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "eza -l";
      la = "eza -la";
      cat = "bat";
      vim = "nvim";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
