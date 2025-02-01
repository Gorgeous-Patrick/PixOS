{
  description = "Customized Zsh Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        zshEnv = pkgs.mkShell {
          buildInputs = [
            pkgs.zsh
            pkgs.git
            pkgs.eza
            pkgs.bat
            pkgs.fzf
            pkgs.zsh-autosuggestions   # Plugin for autosuggestions
            pkgs.zsh-syntax-highlighting  # Plugin for syntax highlighting
          ];

          shell = pkgs.zsh;  # Set Zsh as the default shell

          shellHook = ''
            echo "🚀 Welcome to the Custom Zsh Shell!"

            # Load Zsh plugins
            source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
            source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

            # Aliases
            alias ll='eza -lah'
            alias gs='git status'
            alias gc='git commit -m'
            alias gp='git push'
            alias cat='bat'
            alias cls='clear'

            # Custom Function
            extract() {
              if [ -f "$1" ]; then
                case "$1" in
                  *.tar.bz2)   tar xjf "$1"   ;;
                  *.tar.gz)    tar xzf "$1"   ;;
                  *.bz2)       bunzip2 "$1"   ;;
                  *.gz)        gunzip "$1"    ;;
                  *.tar)       tar xf "$1"    ;;
                  *.zip)       unzip "$1"     ;;
                  *.rar)       unrar x "$1"   ;;
                  *)           echo "'$1' cannot be extracted via extract()" ;;
                esac
              else
                echo "'$1' is not a valid file"
              fi
            }

            # Custom Prompt
            export PS1='%F{cyan}%n@%m%f:%F{yellow}%~%f %# '

            # History Settings
            export HISTSIZE=10000
            export SAVEHIST=10000
            export HISTFILE=~/.zsh_history

            exec zsh  # Launch Zsh
          '';
        };

      in
      {
        devShells.default = zshEnv;

        # Expose as a reusable package
        packages.zshEnv = zshEnv;
      });
}

