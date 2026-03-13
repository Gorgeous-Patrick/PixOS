{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.pixos.bundles.hyprland;
in
{
  options.pixos.bundles.hyprland = {
    enable = lib.mkEnableOption "Hyprland bundle";

    wallpaperPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to wallpaper directory for rotation";
    };

    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Monitor configuration list";
    };
  };

  config = lib.mkIf cfg.enable {
    # ── System-level Hyprland config ──────────────────────────────
    programs.hyprland.enable = true;

    # Greeter (starts Hyprland on login)
    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };

    # Audio
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

    # Fonts
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
      kitty # terminal
      wofi # app launcher
      waybar # status bar
      dunst # notifications
      grim # screenshot
      slurp # region selector
      wl-clipboard
      swww # wallpaper daemon
    ];

    # ── Home Manager config ──────────────────────────────────────
    home-manager.users.patrickli =
      { pkgs, ... }:
      let
        swww-rotate = pkgs.writeShellScriptBin "wallpaper-rotate" ''
          DIR=${if cfg.wallpaperPath != null then cfg.wallpaperPath else "/tmp"}
          while true; do
            WALL=$(find "$DIR" -type f | shuf -n 1)
            echo $WALL
            swww img "$WALL" --transition-type wipe
            sleep 600
          done
        '';
      in
      {
        programs.firefox.enable = true;
        programs.hyprlock.enable = true;
        programs.hyprshot.enable = true;

        home.pointerCursor = {
          gtk.enable = true;
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Classic";
          size = 24;
        };

        wayland.windowManager.hyprland = {
          enable = true;
          settings = {
            "$mod" = "SUPER";

            env = [
              "XCURSOR_SIZE,24"
              "XCURSOR_THEME,Bibata-Modern-Classic"
            ];

            monitor = cfg.monitors;

            exec-once = [
              "waybar"
              "dunst"
              "swww-daemon"
              "nm-applet"
              "blueman-applet"
            ]
            ++ (lib.optional (cfg.wallpaperPath != null) "${swww-rotate}/bin/wallpaper-rotate");

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
              "$mod, S, exec, hyprshot -m region --clipboard-only"

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

              # Fullscreen
              "$mod, F, fullscreen"

              # Enter resize mode
              "$mod, R, submap, resize"

              # Center window
              "$mod SHIFT, C, centerwindow"
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

          extraConfig = ''
            submap = resize
            binde = , H, resizeactive, -20 0
            binde = , L, resizeactive, 20 0
            binde = , K, resizeactive, 0 -20
            binde = , J, resizeactive, 0 20
            binde = , left, resizeactive, -20 0
            binde = , right, resizeactive, 20 0
            binde = , up, resizeactive, 0 -20
            binde = , down, resizeactive, 0 20
            bind = , escape, submap, reset
            submap = reset
          '';
        };
      };
  };
}
