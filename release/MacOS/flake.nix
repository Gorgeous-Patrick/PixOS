{
  description = "PixOS setup for my MacBook";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pixos-nixvim.url = "path:../../applications/nvim-nix";
    nix-update.url = "path:../../applications/nix-update";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      pixos-nixvim,
      nix-update,
    }:
    let
      hostname = "Patricks-MacBook-Air-5";
      platform = "aarch64-darwin";
      username = "patrickli";
      home = "/Users/patrickli";
      homeconfig = import ../../hm/cli-work.nix;
      configuration =
        { pkgs, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
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

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "${platform}";
          users.users.patrickli = {
            name = "${username}";
            home = "${home}";
          };
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."${hostname}" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
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
