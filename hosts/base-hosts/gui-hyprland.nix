{ config, pkgs, ... }:

{
  imports = [
    ./minimal.nix
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

  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # XDG portal for screen-sharing, file-picker, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ];

  # Essential Wayland / Hyprland companion packages
  environment.systemPackages = with pkgs; [
    kitty
    wofi
    waybar
    dunst
    grim
    slurp
    wl-clipboard
    swww
  ];
}
