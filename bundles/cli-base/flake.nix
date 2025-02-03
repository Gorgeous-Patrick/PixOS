{
  description = "Home Manager Flake for PixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        homeConfigurations.patrickli = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            {
              home.stateVersion = "24.11";
              home.packages = [
                pkgs.ranger
                pkgs.thefuck
                pkgs.lazygit
                pkgs.bat
                pkgs.nixfmt-rfc-style
                pkgs.eza
                pkgs.htop
                pkgs.devenv
                pkgs.neofetch
              ];

              programs.git = {
                enable = true;
                userName = "Gorgeous-Patrick";
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
                  ll = "eza -l";
                  lt = "eza --tree";
                  la = "eza -a";
                  lal = "eza -al";
                  v = "nvim";
                  r = "ranger";
                  update = "sudo nixos-rebuild switch";
                  cat = "bat";
                  q = "exit";
                };
                oh-my-zsh = {
                  enable = true;
                  plugins = [ "git" "thefuck" ];
                  theme = "robbyrussell";
                };
              };
            }
          ];
        };
      });
}

