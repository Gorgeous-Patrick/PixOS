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

    pixosMinimalRootPkgs =
      import ./profiles/minimal/rootpkgs.nix { inherit pkgs; };
  in {
    packages.${system} = {
      minimal = pixosMinimalRootPkgs;
      default = pixosMinimalRootPkgs;
    };

    devShells.${system} = {
      minimal = pkgs.mkShell {
        packages = [ pixosMinimalRootPkgs ];
      };

      default = self.devShells.${system}.minimal;
    };
  };
}
