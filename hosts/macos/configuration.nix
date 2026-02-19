# hosts/macos/configuration.nix
{ pkgs, ... }:
{
  # Primary user for nix-darwin
  system.primaryUser = "patrickli";

  # Nix configuration
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "patrickli" ];
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
      # Add GUI apps here, e.g.:
      # "firefox"
      # "visual-studio-code"
      # "iterm2"
    ];
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
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  # Used for backwards compatibility
  system.stateVersion = 5;
}
