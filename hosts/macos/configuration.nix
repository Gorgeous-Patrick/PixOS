# hosts/macos/configuration.nix
{ pkgs, ... }:
{
  # Primary user for nix-darwin
  system.primaryUser = "patrickli";
  nixpkgs.config.allowUnfree = true;

  # Nix configuration
  nix.enable = false;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "patrickli"
    ];
    substituters = [ "https://pixos.cachix.org" ];
    trusted-public-keys = [ "pixos.cachix.org-1:gQmieax+bfq9busdRmxIcvvPcDMl6bQe+n+HRICr1To=" ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
  ];

  # Enable zsh as default shell
  programs.zsh.enable = true;

  # Homebrew integration (optional, for GUI apps)
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    brews = [
      # Add CLI tools from Homebrew here if needed
    ];
    casks = [
      "iterm2"
      "telegram"
    ];
  };

  # Remap Caps Lock to Control
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  # macOS system preferences
  system.defaults = {
    dock = {
      autohide = true;
      mru-spaces = false;
      minimize-to-application = true;
    };
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
    };
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };
  };

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts-color-emoji
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  # Used for backwards compatibility
  system.stateVersion = 5;
  pixos.bundles.gui-misc.enable = true;
  pixos.bundles.git.enable = true;
  pixos.bundles.nvim.enable = true;
  pixos.bundles.zsh.enable = true;
  pixos.bundles.ollama.enable = true;

  nix.extraOptions = ''
    extra-substituters = https://devenv.cachix.org https://unbill.cachix.org
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw= unbill.cachix.org-1:157H1n8eC+rAITRruhXXuS5CUWvSgUIhkzRIbp+AKng=
  '';
}
