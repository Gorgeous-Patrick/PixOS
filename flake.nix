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

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wallpkgs.url = "github:NotAShelf/wallpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixvim,
      nix-darwin,
      wallpkgs,
    }:
    let
      system = "x86_64-linux";
      darwinSystem = "aarch64-darwin";

      pkgs = import nixpkgs {
        inherit system;
      };

      darwinPkgs = import nixpkgs {
        system = darwinSystem;
      };

      pixosMinimalRootPkgs = import ./profiles/minimal/rootpkgs.nix { inherit pkgs; };
      pixosMacosRootPkgs = import ./profiles/macos/rootpkgs.nix { pkgs = darwinPkgs; };
    in
    {
      packages.${system} = {
        minimal = pixosMinimalRootPkgs;
        default = pixosMinimalRootPkgs;
      };

      packages.${darwinSystem} = {
        macos = pixosMacosRootPkgs;
        default = pixosMacosRootPkgs;
      };

      devShells.${system} = {
        minimal = pkgs.mkShell {
          packages = [ pixosMinimalRootPkgs ];
        };
        default = self.devShells.${system}.minimal;
      };

      devShells.${darwinSystem} = {
        macos = darwinPkgs.mkShell {
          packages = [ pixosMacosRootPkgs ];
        };
        default = self.devShells.${darwinSystem}.macos;
      };

      homeConfigurations."minimal" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home/minimal.nix
          nixvim.homeModules.nixvim
        ];
      };

      homeConfigurations."macos" = home-manager.lib.homeManagerConfiguration {
        pkgs = darwinPkgs;
        modules = [
          ./home/macos.nix
          nixvim.homeModules.nixvim
        ];
      };

      # macOS (nix-darwin) configurations
      darwinConfigurations = {
        macos = nix-darwin.lib.darwinSystem {
          system = darwinSystem;
          modules = [
            ./hosts/macos/configuration.nix

            home-manager.darwinModules.home-manager

            (
              { ... }:
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;

                home-manager.users.patrickli = import ./home/macos.nix;

                home-manager.sharedModules = [
                  nixvim.homeManagerModules.nixvim
                ];
              }
            )
          ];
        };
      };

      # ✅ NEW: NixOS host configs
      nixosConfigurations = {
        kvm-minimal = nixpkgs.lib.nixosSystem {
          inherit system;

          modules = [
            ./hosts/kvm-minimal/configuration.nix

            # Home Manager integrated into NixOS
            home-manager.nixosModules.home-manager

            (
              { ... }:
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;

                home-manager.users.patrickli = import ./home/minimal.nix;

                # If you want nixvim available in HM on NixOS:
                home-manager.sharedModules = [
                  nixvim.homeManagerModules.nixvim
                ];
              }
            )
          ];
        };

        kvm-gui-hyprland = nixpkgs.lib.nixosSystem {
          inherit system;

          modules = [
            ./hosts/kvm-gui-hyprland/configuration.nix

            home-manager.nixosModules.home-manager

            (
              { ... }:
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;

                home-manager.users.patrickli = import ./home/gui-hyprland.nix;

                home-manager.sharedModules = [
                  nixvim.homeManagerModules.nixvim
                ];
              }
            )
          ];
        };

        framework = nixpkgs.lib.nixosSystem {
          inherit system;

          modules = [
            ./hosts/framework/configuration.nix

            home-manager.nixosModules.home-manager

            (
              { ... }:
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;

                home-manager.users.patrickli = import ./home/gui-hyprland.nix;

                home-manager.sharedModules = [
                  nixvim.homeManagerModules.nixvim
                ];
              }
            )
          ];
        };

        iso-minimal = nixpkgs.lib.nixosSystem {
          inherit system;

          modules = [
            ./hosts/iso-minimal/configuration.nix

            home-manager.nixosModules.home-manager

            (
              { ... }:
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;

                home-manager.users.patrickli = import ./home/minimal.nix;

                home-manager.sharedModules = [
                  nixvim.homeManagerModules.nixvim
                ];
              }
            )
          ];
        };
      };
    };
}
