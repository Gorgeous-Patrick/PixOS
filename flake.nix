{
  description = "PixOS — minimal, reusable Nix environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
    };

    pixosMinimal = import ./profiles/minimal.nix {
      inherit pkgs;
    };
  in {
    packages.${system} = {
      minimal = pixosMinimal;
      default = pixosMinimal;
    };

    devShells.${system} = {
      minimal = pkgs.mkShell {
        packages = [ pixosMinimal ];
      };

      default = self.devShells.${system}.minimal;
    };
  };
}
