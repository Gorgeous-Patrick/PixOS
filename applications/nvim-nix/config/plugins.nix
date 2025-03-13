{
  config,
  pkgs,
  lib,
  ...
}:
{
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
  plugins.flash = {
    enable = true;
    settings = {

      search = {
        mode = "fuzzy";
      };
      jump = {
        autojump = true;
      };
      label = {
        uppercase = false;
        rainbow = {
          enabled = true;
          shade = 5;
        };
      };
    };
  };
  plugins.diffview.enable = true;
  opts = {
    number = true; # Show line numbers
    relativenumber = true; # Show relative line numbers
    shiftwidth = 2; # Tab width should be 2
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
    nvim-treesitter-parsers.lalrpop
  ];
}
