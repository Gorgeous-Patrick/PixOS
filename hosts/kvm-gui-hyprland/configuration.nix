{ config, pkgs, ... }:
{
  imports = [
    ../kvm-minimal/configuration.nix
  ];

  # ── Hyprland (Wayland compositor) ──────────────────────────────
  programs.hyprland.enable = true;

  # Greeter (starts Hyprland on login)
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
      user = "greeter";
    };
  };

  # XDG portal for screen-sharing, file-picker, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Essential Wayland / Hyprland companion packages
  environment.systemPackages = with pkgs; [
    kitty              # GPU-accelerated terminal
    wofi               # App launcher
    waybar             # Status bar
    dunst              # Notification daemon
    grim               # Screenshot tool
    slurp              # Region selector for grim
    wl-clipboard       # Clipboard support
    swww               # Wallpaper daemon
  ];
}
