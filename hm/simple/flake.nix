{
  description = "Simple Combined Flake for PixOS with CLI Base and Neovim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";

    # Import the CLI Base flake
    cli-base = {
      url = "path:../bundles/cli-base.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Import the Neovim flake
    nvim-config = {
      url = "path:../applications/nvim-nix/nvim.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Optionally include Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, cli-base, nvim-config, home-manager, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        homeConfigurations.patrickli = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            cli-base.homeManagerModules.default
            nvim-config.homeManagerModules.nixvim
          ];
        };
      });
}

