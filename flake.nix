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
      url = "github:LighghtEeloo/charcoal/v0.3.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wallpkgs.url = "github:NotAShelf/wallpkgs";

    unbill.url = "github:unbill-project/unbill/main";

    herdr.url = "github:herdrdev/herdr/v0.9.3";

    herdr-nvim = {
      url = "github:ChmaraX/herdr-nvim/v1.1.0";
      flake = false;
    };

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

    codex-nix = {
      url = "github:SecBear/codex-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
      herdr,
      herdr-nvim,
      firefox-addons,
      jac-nvim,
      tree-sitter-jac,
      codex-nix,
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
        codex = codex-nix.packages.${final.stdenv.hostPlatform.system}.default;
        herdr = herdr.packages.${final.stdenv.hostPlatform.system}.default;
        herdr-nvim = final.rustPlatform.buildRustPackage {
          pname = "herdr-nvim";
          version = (builtins.fromTOML (builtins.readFile "${herdr-nvim}/Cargo.toml")).package.version;
          src = herdr-nvim;
          cargoLock.lockFile = "${herdr-nvim}/Cargo.lock";

          nativeBuildInputs = [
            final.pkg-config
            final.makeWrapper
          ];
          buildInputs = [ final.zlib ];
          nativeCheckInputs = [
            final.gitMinimal
            final.neovim-unwrapped
            final.which
          ]
          ++ final.lib.optionals final.stdenv.hostPlatform.isLinux [
            final.procps
            final.util-linux
          ];

          preCheck = ''
            # The picker test uses git ls-files; flake source archives omit .git.
            git init -q
            git add .
          '';

          postCheck = ''
            nvim --headless --noplugin -u NONE -l tests/run.lua
          '';

          postInstall = ''
            # The daemon finds its Lua runtime by walking up from bin/herdr-nvim.
            cp -r lua plugin doc "$out/"
            # Nix builds the binary; herdr must not download or rebuild it.
            sed '/^\[\[build\]\]/,$d' herdr-plugin.toml > "$out/herdr-plugin.toml"
            wrapProgram "$out/bin/herdr-nvim" \
              --prefix PATH : "${
                final.lib.makeBinPath (
                  [
                    final.gitMinimal
                    final.herdr
                  ]
                  ++ final.lib.optionals final.stdenv.hostPlatform.isLinux [ final.procps ]
                )
              }"
          '';

          meta = {
            description = "Neovim sidebar and file picker for herdr";
            homepage = "https://github.com/ChmaraX/herdr-nvim";
            license = final.lib.licenses.mit;
            mainProgram = "herdr-nvim";
            platforms = final.lib.platforms.unix;
          };
        };

        herdr-nvim-plugin = final.vimUtils.buildVimPlugin {
          pname = "herdr-nvim";
          inherit (final.herdr-nvim) version;
          src = herdr-nvim;
          installPhase = ''
            runHook preInstall
            mkdir -p "$out"
            cp -r lua plugin doc "$out/"
            runHook postInstall
          '';
        };

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
        config.allowUnfree = true;
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
            ./hosts/base-hosts/cache.nix
            {
              _module.args.pixosIsDarwin = false;
            }
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
      # darwin-specific. The Homebrew companion bundles are imported only here.
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
            ./hosts/base-hosts/cache.nix
            sops-nix.darwinModules.sops
            { _module.args.pixosIsDarwin = true; }
          ]
          ++ map bundle bundles
          ++ [
            (bundle "firefox-darwin")
            (bundle "gui-misc-darwin")
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
      # Import into a machine's NixOS configuration alongside its own hardware,
      # bootloader, stateVersion, and SSH authorized keys.
      nixosModules.server = {
        imports = [
          ./hosts/base-hosts/server.nix
          ./hosts/base-hosts/cache.nix
          home-manager.nixosModules.home-manager
          (hmWiring ./home/server.nix)
        ]
        ++ map bundle [
          "git"
          "zsh"
          "nvim"
        ];
        _module.args.pixosIsDarwin = false;
        nixpkgs.overlays = [ pixosOverlay ];
      };

      packages.${system} = {
        minimal = pixosMinimalRootPkgs;
        default = pixosMinimalRootPkgs;
        server-iso = self.nixosConfigurations.iso-server.config.system.build.isoImage;
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
          "latex"
          "zsh"
          "firefox"
          "sops"
          "ssh-keys"
          "concord"
        ];
      };

      # NixOS hosts
      nixosConfigurations = {
        iso-server = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            self.nixosModules.server
            ./hosts/iso-server/configuration.nix
          ];
        };

        kvm-minimal = mkNixosHost {
          hostModule = ./hosts/kvm-minimal/configuration.nix;
          homeModule = ./home/minimal.nix;
          bundles = [
            "nvim"
            "latex"
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
            "latex"
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
            "davinci-resolve"
            "google-drive"
            "nvim"
            "latex"
            "zsh"
            "ollama"
            "fprintd"
            "web-dev"
            "niri"
            "fcitx5"
            "sops"
            "ssh-keys"
            "concord"
          ];
        };

        iso-minimal = mkNixosHost {
          hostModule = ./hosts/iso-minimal/configuration.nix;
          homeModule = ./home/minimal.nix;
          bundles = [
            "git"
            "nvim"
            "latex"
            "zsh"
          ];
        };
      };
    };
}
