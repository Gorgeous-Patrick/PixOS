{
  description = "PixOS — minimal, reusable Nix environment (WSL-safe)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixvim }:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
    };

    # Root/baseline bundle (meta-package) for the minimal profile
    pixosMinimalRootPkgs =
      import ./profiles/minimal/rootpkgs.nix { inherit pkgs; };
  in {
    # Export the minimal root bundle as a package
    packages.${system} = {
      minimal = pixosMinimalRootPkgs;
      default = pixosMinimalRootPkgs;
    };

    # A dev shell that includes the minimal root bundle (handy for quick testing)
    devShells.${system} = {
      minimal = pkgs.mkShell {
        packages = [ pixosMinimalRootPkgs ];
      };

      default = self.devShells.${system}.minimal;
    };

    # Home Manager configuration (your "minimal HM")
    homeConfigurations."patrickli" =
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home/minimal.nix
          nixvim.homeManagerModules.nixvim
        ];
      };
  };
}
