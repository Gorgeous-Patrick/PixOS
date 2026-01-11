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

  };

  programs.git = {
    enable = true;
    userName = "Patrick Li";
    userEmail = "baichuanli@yahoo.com";
  };
}
