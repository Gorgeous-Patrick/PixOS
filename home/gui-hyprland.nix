{ pkgs, ... }:
{
  imports = [
    ./minimal.nix
  ];
  programs.firefox.enable = true;
  programs.hyprlock.enable = true;
  programs.hyprshot.enable = true;
  programs.discord.enable = true;

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  # ── Hyprland (Wayland window manager) ──────────────────────
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";

      env = [
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,Bibata-Modern-Classic"
      ];

      monitor = [
        "DP-3, 3440x1440, 0x0, 1"
        "eDP-1, 2880x1920, 0x1440, 2"
        "DP-4, 1920x1080, 3440x0, 1, transform, 1"
      ];

      exec-once = [
        "waybar"
        "dunst"
        "swww-daemon"
        "nm-applet"
        "blueman-applet"
      ];

      general = {
        gaps_in = 0;
        gaps_out = 5;
        border_size = 2;
        layout = "master";
      };

      decoration = {
        rounding = 3;
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        kb_options = "ctrl:nocaps";
        touchpad.natural_scroll = true;
      };

      bind = [
        "$mod, Return, exec, kitty"
        "$mod, Q, killactive"
        "$mod, M, exit"
        "$mod, Z, exec, wofi --show drun"
        "$mod, X, exec, firefox"
        "$mod, Space, togglefloating"
        "$mod, P, pseudo"
        "$mod, J, togglesplit"

        # Move focus
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"

        # Move to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"

        # Move Window

        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, J, movewindow, d"

        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"

        # Screenshot
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"

        # Fullscreen current window with Mod+F
        "$mod, F, fullscreen"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      misc = {
        "disable_hyprland_logo" = true;
        "disable_splash_rendering" = true;
      };
    };
  };
}
