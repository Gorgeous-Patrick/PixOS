{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    pixos-nixvim.url = "path:../../applications/nvim-nix";
    nix-update.url = "path:../../applications/nix-update";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
      pixos-nixvim,
      nix-update,
      home-manager,
    }:

    let
      platform = "x86_64-linux";
      hostname = "nixos";
      username = "patrickli";
      homeconfig = import ../../hm/cli-work.nix;
      config =
        {
          config,
          lib,
          pkgs,
          ...
        }:

        {
          environment.systemPackages = [
            pkgs.vim
            pkgs.zsh
            pkgs.nano
            pkgs.wget
            pkgs.curl
            pixos-nixvim.packages."${platform}".default
            nix-update.packages."${platform}".rebuild
            nix-update.packages."${platform}".update
          ];
          programs.zsh.enable = true;
          users.defaultUserShell = pkgs.zsh;
        };
    in
    {
      # replace 'joes-desktop' with your hostname here.
      nixosConfigurations."${hostname}" = nixpkgs.lib.nixosSystem {
        system = platform;
        modules = [
          ./configuration.nix
          nixos-wsl.nixosModules.wsl
          config
          home-manager.nixosModules.home-manager

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.verbose = true;
            home-manager.users."${username}" = homeconfig;
          }
        ];
      };
    };
}
