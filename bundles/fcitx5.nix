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
      fcitx5.addons = with pkgs; [
        fcitx5-rime
        qt6Packages.fcitx5-chinese-addons
      ];
    };

    home-manager.users.patrickli =
      { ... }:
      {
        # Rime default config: use Xiaohe Shuangpin
        home.file.".local/share/fcitx5/rime/default.custom.yaml".text = ''
          patch:
            schema_list:
              - schema: double_pinyin_flypy
        '';
      };
  };
}
