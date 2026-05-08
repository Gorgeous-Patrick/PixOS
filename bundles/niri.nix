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
  options.pixos.bundles.niri.enable = lib.mkEnableOption "niri bundle";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      niri
    ];

    # Audio
    services.pipewire = {
      enable = true;
      audio.enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
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
  };
}
