{
  description = "Builds a NixOS installer ISO with some useful stuff in it.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
    };
  };

  outputs = { self, nixpkgs, nixos-generators, ... }:
  let
    system = "x86_64-linux";
  in
  {
    packages.${system}.default = nixos-generators.nixosGenerate {
      system = system;
      format = "install-iso";
      modules = [ ../../system/system.nix ];
    };
  };
}
