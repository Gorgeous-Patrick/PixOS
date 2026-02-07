{
  description = "PixOS — minimal, reusable Nix environment (WSL-safe)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixvim }:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
    };

    pixosMinimalRootPkgs =
      import ./profiles/minimal/rootpkgs.nix { inherit pkgs; };
  in
  {
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

    homeConfigurations."minimal" =
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home/minimal.nix
          nixvim.homeManagerModules.nixvim
        ];
      };

    # ✅ NEW: NixOS host configs
    nixosConfigurations = {
      xps = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./hosts/kvm/configuration.nix

          # Home Manager integrated into NixOS
          home-manager.nixosModules.home-manager

          ({ ... }: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.patrickli = import ./home/minimal.nix;

            # If you want nixvim available in HM on NixOS:
            home-manager.sharedModules = [
              nixvim.homeManagerModules.nixvim
            ];
          })
        ];
      };
    };
  };
}
