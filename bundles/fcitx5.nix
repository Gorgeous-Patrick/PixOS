{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.pixos.bundles.fcitx5;
in
{
  options.pixos.bundles.fcitx5.enable = lib.mkEnableOption "fcitx5 with Rime (Xiaohe Shuangpin)";

  config = lib.mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          fcitx5-rime
          qt6Packages.fcitx5-chinese-addons
        ];

        settings = {
          globalOptions = {
            Hotkey = {
              # Use deliberate shortcuts, not a tap of Shift or Ctrl.
              AltTriggerKeys = "";
              EnumerateWithTriggerKeys = "False";
              EnumerateForwardKeys = "";
              EnumerateBackwardKeys = "";
              EnumerateGroupForwardKeys = "";
              EnumerateGroupBackwardKeys = "";
            };
            "Hotkey/TriggerKeys"."0" = "Control+space"; # Toggle English / Rime
            "Hotkey/ActivateKeys"."0" = "Control+Alt+c"; # Rime (Chinese)
            "Hotkey/DeactivateKeys"."0" = "Control+Alt+e"; # English
          };

          inputMethod = {
            GroupOrder."0" = "Default";
            "Groups/0" = {
              Name = "Default";
              "Default Layout" = "us";
              DefaultIM = "rime";
            };
            "Groups/0/Items/0".Name = "keyboard-us";
            "Groups/0/Items/1".Name = "rime";
          };
        };
      };
    };

    home-manager.users.patrickli =
      hm@{ lib, ... }:
      {
        # Per-user files override /etc/xdg. Link the same Nix-generated files
        # here, without ignoreUserConfig (which also disables user dictionaries).
        xdg.configFile = lib.genAttrs [ "fcitx5/config" "fcitx5/profile" ] (name: {
          source = config.environment.etc."xdg/${name}".source;
          force = true;
        });

        # Adopt existing GUI-written files without losing them on first switch.
        home.activation.backupFcitx5Config =
          lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ]
            ''
              for name in config profile; do
                target=${lib.escapeShellArg hm.config.xdg.configHome}/fcitx5/"$name"
                if [ -e "$target" ] && [ ! -L "$target" ]; then
                  run ${pkgs.coreutils}/bin/mv --backup=numbered -- "$target" "$target.before-nix"
                fi
              done
            '';

        # Rime default config: use Xiaohe Shuangpin
        home.file.".local/share/fcitx5/rime/default.custom.yaml".text = ''
          patch:
            schema_list:
              - schema: double_pinyin_flypy
            # Rime has its own Shift toggles in addition to Fcitx5's.
            "ascii_composer/switch_key/Shift_L": noop
            "ascii_composer/switch_key/Shift_R": noop
        '';

        # Use simplified Chinese by default
        home.file.".local/share/fcitx5/rime/double_pinyin_flypy.custom.yaml".text = ''
          patch:
            "switches/@2/reset": 1
        '';
      };
  };
}
