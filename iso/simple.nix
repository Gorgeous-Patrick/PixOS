{ pkgs, modulesPath, lib, ... }: {
  imports = [
   <home-manager/nixos>
    # base profiles
    "${modulesPath}/profiles/base.nix"
    "${modulesPath}/profiles/all-hardware.nix"
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
  ];
  system.stateVersion = "24.11";

  # use the latest Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Needed for https://github.com/NixOS/nixpkgs/issues/58959
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
  # ISO naming.
  isoImage.isoName = "PixOS-simple.iso";

  users.mutableUsers = true;
  users.groups.patrickli = {};
  users.users.patrickli = {
    initialPassword = "password";
    isSystemUser = false;
    group = "patrickli";
    extraGroups = ["wheel"];
  };
  home-manager.users.patrickli = import ../hm/cli-work.nix;
  
}
