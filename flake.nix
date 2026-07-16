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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    concord = {
      url = "github:chojs23/concord";
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

    jac-nvim = {
      url = "github:chess10kp/jac.nvim";
      flake = false;
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
      sops-nix,
      concord,
      nix-darwin,
      charcoal,
      wallpkgs,
      unbill,
      firefox-addons,
      jac-nvim,
      tree-sitter-jac,
    }:
    let
      system = "x86_64-linux";
      darwinSystem = "aarch64-darwin";

      # ── One overlay to carry every external input ──────────────────────────
      # Each flake input that provides a package (or, for wallpkgs, a source
      # tree) is exposed here as a `pkgs.*` attribute. This is the single place
      # inputs enter the package set — modules then reach them via `pkgs.foo`
      # with no per-host specialArgs threading. Applied to every host below and
      # to the standalone pkgs sets, so the mechanism is uniform everywhere.
      pixosOverlay = final: _: {
        inherit (unbill.packages.${final.stdenv.hostPlatform.system})
          unbill-daemon
          unbill-tui
          unbill-tauri
          ;

        concord-tui = concord.packages.${final.stdenv.hostPlatform.system}.default;
        charcoal = charcoal.packages.${final.stdenv.hostPlatform.system}.default;
        firefox-addons = firefox-addons.packages.${final.stdenv.hostPlatform.system};

        # Not a package — the wallpaper source tree, consumed as a path.
        inherit wallpkgs;

        jac-nvim = final.vimUtils.buildVimPlugin {
          pname = "jac.nvim";
          version = jac-nvim.shortRev or "unstable";
          src = jac-nvim;
        };

        tree-sitter-jac-plugin = final.neovimUtils.grammarToPlugin (
          final.tree-sitter.buildGrammar {
            language = "jac";
            version = tree-sitter-jac.shortRev or "unstable";
            src = tree-sitter-jac;
          }
        );
      };

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ pixosOverlay ];
      };

      darwinPkgs = import nixpkgs {
        system = darwinSystem;
        overlays = [ pixosOverlay ];
      };

      # ── Host builders ──────────────────────────────────────────────────────
      # bundles/<name>.nix, referenced by short name in host definitions.
      bundle = name: ./bundles + "/${name}.nix";

      # Home-manager wiring shared by every host (NixOS and Darwin). Only the
      # user's home module differs per host; the rest is identical boilerplate
      # that used to be copy-pasted into each configuration.
      hmWiring = homeModule: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.patrickli = import homeModule;
        home-manager.sharedModules = [ nixvim.homeModules.nixvim ];
      };

      # All four Linux hosts share this shape. They differ only in host module,
      # home module, bundle set, and whether sops-nix is included.
      mkNixosHost =
        {
          hostModule,
          homeModule,
          bundles ? [ ],
          sops ? false,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            hostModule
          ]
          ++ nixpkgs.lib.optional sops sops-nix.nixosModules.sops
          ++ map bundle bundles
          ++ [
            { nixpkgs.overlays = [ pixosOverlay ]; }
            home-manager.nixosModules.home-manager
            (hmWiring homeModule)
          ];
        };

      # The sole Darwin host. Separate from mkNixosHost because the builder,
      # system, and home-manager / sops / nixvim module paths are all
      # darwin-specific. bundles/firefox-darwin.nix (the Homebrew Firefox cask)
      # is darwin-only and so is imported only here.
      mkDarwinHost =
        {
          hostModule,
          homeModule,
          bundles ? [ ],
        }:
        nix-darwin.lib.darwinSystem {
          system = darwinSystem;
          modules = [
            hostModule
            sops-nix.darwinModules.sops
          ]
          ++ map bundle bundles
          ++ [
            (bundle "firefox-darwin")
            { nixpkgs.overlays = [ pixosOverlay ]; }
            nixvim.nixDarwinModules.nixvim
            home-manager.darwinModules.home-manager
            (hmWiring homeModule)
          ];
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

      # Standalone home-manager configs. charcoal now comes from the overlaid
      # pkgs (pkgs.charcoal), so no extraSpecialArgs are needed.
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

      # macOS (nix-darwin)
      darwinConfigurations.macos = mkDarwinHost {
        hostModule = ./hosts/macos/configuration.nix;
        homeModule = ./home/macos.nix;
        bundles = [
          "git"
          "gui-misc"
          "nvim"
          "zsh"
          "ollama"
          "firefox"
          "sops"
          "concord"
        ];
      };

      # NixOS hosts
      nixosConfigurations = {
        kvm-minimal = mkNixosHost {
          hostModule = ./hosts/kvm-minimal/configuration.nix;
          homeModule = ./home/minimal.nix;
          bundles = [
            "nvim"
            "zsh"
          ];
        };

        kvm-gui-hyprland = mkNixosHost {
          hostModule = ./hosts/kvm-gui-hyprland/configuration.nix;
          homeModule = ./home/gui-hyprland.nix;
          bundles = [
            "hyprland"
            "firefox"
            "nvim"
            "zsh"
          ];
        };

        framework = mkNixosHost {
          hostModule = ./hosts/framework/configuration.nix;
          homeModule = ./home/gui-hyprland.nix;
          sops = true;
          bundles = [
            "git"
            "hyprland"
            "firefox"
            "gui-misc"
            "nvim"
            "zsh"
            "ollama"
            "fprintd"
            "web-dev"
            "niri"
            "fcitx5"
            "sops"
            "concord"
          ];
        };

        iso-minimal = mkNixosHost {
          hostModule = ./hosts/iso-minimal/configuration.nix;
          homeModule = ./home/minimal.nix;
          bundles = [
            "git"
            "nvim"
            "zsh"
          ];
        };
      };
    };
}
