{
  description = "Builds a NixOS installer ISO with some useful stuff in it.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
    };
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-generators, home-manager, ... }:
  let
    system = "x86_64-linux";
  in
  {
    packages.${system}.default = nixos-generators.nixosGenerate {
      system = system;
      format = "iso";
      modules = [
          home-manager.nixosModules.home-manager
          ../../system/system.nix
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.patrickli = import ../../hm/simple.nix;
          }
      ];
    };
  };
}
