{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.pixos.bundles.zsh;
in
{
  options.pixos.bundles.zsh = {
    enable = lib.mkEnableOption "Zsh bundle";

    terminal = lib.mkOption {
      type = lib.types.enum [
        "kitty"
        "alacritty"
        "foot"
        "wezterm"
        "none"
      ];
      default = "none";
      description = "Terminal emulator to install alongside zsh";
    };
  };

  config = lib.mkIf cfg.enable {
    # Zsh depends on nvim bundle (for `v` alias)
    pixos.bundles.nvim.enable = true;

    # Shell utilities that zsh aliases depend on
    environment.systemPackages = with pkgs; [
      eza # ls replacement
      bat # cat replacement
      ranger # file manager
      duf # df replacement
      dust # du replacement
    ];

    home-manager.users.patrickli =
      { pkgs, ... }:
      {
        programs.zsh = {
          enable = true;
          enableCompletion = true;
          initExtraFirst = ''
            echo Welcome to PixOS!
          '';
          shellAliases = {
            ls = "eza --icons";
            ll = "ls -l";
            lt = "ls --tree";
            la = "ls -a";
            lal = "ls -al";
            v = "nvim";
            r = "ranger";
            cat = "bat";
            q = "exit";
            c = "clear";
            g = "lazygit";
            hiber = "hyprlock & systemctl hibernate";
            df = "${pkgs.duf}/bin/duf";
            du = "${pkgs.dust}/bin/dust";
            open = "xdg-open";
          };
          oh-my-zsh = {
            enable = true;
            plugins = [ "git" ];
            theme = "robbyrussell";
          };
        };

        programs.direnv.enable = true;

        # Terminal emulator
        programs.kitty.enable = cfg.terminal == "kitty";
        programs.alacritty.enable = cfg.terminal == "alacritty";
        programs.foot.enable = cfg.terminal == "foot";
        programs.wezterm.enable = cfg.terminal == "wezterm";
      };
  };
}
