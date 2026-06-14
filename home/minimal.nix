{
  pkgs,
  lib,
  wallpkgs,
  charcoalPkg ? null,
  ...
}:
{
  home.username = "patrickli";
  home.homeDirectory = "/home/patrickli";
  home.stateVersion = "25.11";

  # Linux-oriented base package set. Skipped on Darwin, where home/macos.nix
  # provides the macOS list instead (this lets bundle packages merge in rather
  # than being clobbered by a mkForce override).
  home.packages = lib.optionals (!pkgs.stdenv.isDarwin) (
    import ../profiles/minimal/hm/packages.nix {
      inherit pkgs;
      charcoal = charcoalPkg;
    }
  );

  programs.home-manager.enable = true;
  programs.gh.enable = true;
  programs.ripgrep.enable = true;

  services.syncthing = {
    enable = true;
    settings = {
      devices = {
        "vultr" = {
          id = "UQSOBLO-VSYHIY3-4JVNHYF-UPNIMZ3-ET7G5TB-DCUEWCB-IGTM7DC-DWE7VAM";
        };
      };
    };
  };

  programs.zellij.enable = true;
}
