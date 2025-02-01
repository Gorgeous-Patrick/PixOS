{
  description = "A Nix Flake bundling common CLI tools like zsh, nvim, eza, etc.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        tools = with pkgs; [
          zsh
          neovim    # Modern Vim
          eza       # Replacement for 'ls'
          git       # Version control
          curl      # HTTP client
          htop      # Process viewer
          fzf       # Fuzzy finder
          ripgrep   # Fast grep alternative
          tmux      # Terminal multiplexer
          bat       # Syntax highlighting for cat
          jq        # JSON processor
          tree      # Directory structure viewer
          httpie    # User-friendly HTTP client
        ];
      in
      {
        packages.default = pkgs.buildEnv {
          name = "pixos-cli-tools";
          paths = tools;
        };
      });
}

