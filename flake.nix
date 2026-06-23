{
  description = "PixOS — minimal, reusable Nix environment (WSL-safe)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    charcoal = {
      url = "github:LighghtEeloo/charcoal/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wallpkgs.url = "github:NotAShelf/wallpkgs";

    unbill.url = "github:unbill-project/unbill/main";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tree-sitter-jac = {
      url = "github:jaseci-labs/tree-sitter-jac";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixvim,
      nix-darwin,
      charcoal,
      wallpkgs,
      unbill,
      firefox-addons,
      tree-sitter-jac,
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

      unbillOverlay = final: _: {
        inherit (unbill.packages.${final.stdenv.hostPlatform.system}) unbill-daemon unbill-tui unbill-tauri;
      };

      treeSitterJacOverlay = final: _: {
        tree-sitter-jac-grammar = final.tree-sitter.buildGrammar {
          language = "jac";
          version = tree-sitter-jac.shortRev or "unstable";
          src = tree-sitter-jac;
        };
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
        extraSpecialArgs = {
          charcoalPkg = charcoal.packages.${system}.default;
        };
        modules = [
          ./home/minimal.nix
          nixvim.homeModules.nixvim
        ];
      };

      homeConfigurations."macos" = home-manager.lib.homeManagerConfiguration {
        pkgs = darwinPkgs;
        extraSpecialArgs = {
          charcoalPkg = charcoal.packages.${darwinSystem}.default;
        };
        modules = [
          ./home/macos.nix
          nixvim.homeModules.nixvim
        ];
      };

      # macOS (nix-darwin) configurations
      darwinConfigurations = {
        macos = nix-darwin.lib.darwinSystem {
          system = darwinSystem;
          specialArgs = {
            firefoxAddons = firefox-addons.packages.${darwinSystem};
          };
          modules = [
            ./hosts/macos/configuration.nix
            ./bundles/git.nix
            ./bundles/gui-misc.nix
            ./bundles/nvim.nix
            ./bundles/zsh.nix
            ./bundles/ollama.nix
            ./bundles/firefox.nix

            # Darwin-only: Firefox.app comes from Homebrew since nixpkgs has
            # no working macOS Firefox bundle. Lives here (not in the bundle)
            # because `homebrew.*` is a nix-darwin-only option.
            (
              { config, lib, ... }:
              {
                config = lib.mkIf config.pixos.bundles.firefox.enable {
                  homebrew.casks = [ "firefox" ];
                };
              }
            )

            {
              nixpkgs.overlays = [
                unbillOverlay
                treeSitterJacOverlay
              ];
            }

            nixvim.nixDarwinModules.nixvim
            home-manager.darwinModules.home-manager

            (
              { ... }:
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;

                home-manager.extraSpecialArgs = {
                  charcoalPkg = charcoal.packages.${darwinSystem}.default;
                };

                home-manager.users.patrickli = import ./home/macos.nix;

                home-manager.sharedModules = [
                  nixvim.homeModules.nixvim
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

            ./bundles/nvim.nix
            ./bundles/zsh.nix

            {
              nixpkgs.overlays = [
                unbillOverlay
                treeSitterJacOverlay
              ];
            }

            # Home Manager integrated into NixOS
            home-manager.nixosModules.home-manager

            (
              { ... }:
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;

                home-manager.extraSpecialArgs = {
                  charcoalPkg = charcoal.packages.${system}.default;
                };

                home-manager.users.patrickli = import ./home/minimal.nix;

                # If you want nixvim available in HM on NixOS:
                home-manager.sharedModules = [
                  nixvim.homeModules.nixvim
                ];
              }
            )
          ];
        };

        kvm-gui-hyprland = nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            firefoxAddons = firefox-addons.packages.${system};
          };

          modules = [
            ./hosts/kvm-gui-hyprland/configuration.nix

            ./bundles/hyprland.nix
            ./bundles/firefox.nix
            ./bundles/nvim.nix
            ./bundles/zsh.nix

            {
              nixpkgs.overlays = [
                unbillOverlay
                treeSitterJacOverlay
              ];
            }

            home-manager.nixosModules.home-manager

            (
              { ... }:
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = {
                  charcoalPkg = charcoal.packages.${system}.default;
                };

                home-manager.users.patrickli = import ./home/gui-hyprland.nix;

                home-manager.sharedModules = [
                  nixvim.homeModules.nixvim
                ];
              }
            )
          ];
        };

        framework = nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit wallpkgs;
            firefoxAddons = firefox-addons.packages.${system};
          };

          modules = [
            ./hosts/framework/configuration.nix

            ./bundles/git.nix
            ./bundles/hyprland.nix
            ./bundles/firefox.nix
            ./bundles/gui-misc.nix
            ./bundles/nvim.nix
            ./bundles/zsh.nix
            ./bundles/ollama.nix
            ./bundles/fprintd.nix
            ./bundles/web-dev.nix
            ./bundles/niri.nix
            ./bundles/fcitx5.nix

            {
              nixpkgs.overlays = [
                unbillOverlay
                treeSitterJacOverlay
              ];
            }

            home-manager.nixosModules.home-manager

            (
              { ... }:
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = {
                  charcoalPkg = charcoal.packages.${system}.default;
                };

                home-manager.users.patrickli = import ./home/gui-hyprland.nix;

                home-manager.sharedModules = [
                  nixvim.homeModules.nixvim
                ];
              }
            )
          ];
        };

        iso-minimal = nixpkgs.lib.nixosSystem {
          inherit system;

          modules = [
            ./hosts/iso-minimal/configuration.nix

            ./bundles/nvim.nix
            ./bundles/zsh.nix

            {
              nixpkgs.overlays = [
                unbillOverlay
                treeSitterJacOverlay
              ];
            }

            home-manager.nixosModules.home-manager

            (
              { ... }:
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;

                home-manager.extraSpecialArgs = {
                  charcoalPkg = charcoal.packages.${system}.default;
                };

                home-manager.users.patrickli = import ./home/minimal.nix;

                home-manager.sharedModules = [
                  nixvim.homeModules.nixvim
                ];
              }
            )
          ];
        };
      };
    };
}
