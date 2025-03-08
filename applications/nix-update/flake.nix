{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixvim.url = "github:nix-community/nixvim";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs =
    { nixpkgs, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        { system, pkgs, ... }:
        let
          update = if system=="aarch64-darwin" then pkgs.writeShellScriptBin "update" "echo 'hello'" else nixpkgs.legacyPackages.${system}.hello;
        in
        {
          packages = {
            # Lets you run `nix run .` to start nixvim
            default = update;
          };
        };
    };
}
