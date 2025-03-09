{
  pkgs,
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    <home-manager/nixos>
    # base profiles
    "${modulesPath}/profiles/base.nix"
    "${modulesPath}/profiles/all-hardware.nix"
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];
  system.stateVersion = "24.11";

  # use the latest Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Needed for https://github.com/NixOS/nixpkgs/issues/58959
  boot.supportedFilesystems = lib.mkForce [
    "btrfs"
    "reiserfs"
    "vfat"
    "f2fs"
    "xfs"
    "ntfs"
    "cifs"
  ];
  # ISO naming.
  isoImage.isoName = "PixOS-simple.iso";

  environment.systemPackages = with pkgs; [
    nano
    wget
    curl
    docker
  ];
  virtualisation.docker.enable = true;

  programs.zsh.enable = true;

  users.mutableUsers = true;
  users.groups.patrickli = { };
  users.users.patrickli = {
    initialPassword = "password";
    isNormalUser = true;
    group = "patrickli";
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
  };
  home-manager.users.patrickli = import ../hm/cli-work.nix;

}
