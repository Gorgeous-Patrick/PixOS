{
  description = "Overview Flake Importing CLI Toolkit and Other Tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Local reference to CLI toolkit flake
    cli-tools.url = "./bundles/cli-tools";
  };

  outputs = { self, nixpkgs, flake-utils, cli-tools }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # Dev Shell that includes everything from cli-toolkit
        devShells.default = pkgs.mkShell {
          buildInputs = [
            cli-tools.packages.${system}.default
            pkgs.zsh  # Ensure Zsh is included
          ];
          shellHook = ''
            echo "Welcome to the Overview Environment 🚀"
            echo "CLI Tools from cli-toolkit are loaded!"
            export SHELL=$(which zsh)
            exec zsh
          '';
        };

      });
}

