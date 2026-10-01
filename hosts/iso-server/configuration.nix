{ lib, modulesPath, ... }:

{
  imports = [ "${modulesPath}/installer/cd-dvd/iso-image.nix" ];

  networking.hostName = "pixos-server";
  system.stateVersion = "26.05";
  isoImage = {
    edition = "pixos-server";
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  # Live console access; remote SSH still requires an authorized key.
  services.getty.autologinUser = "patrickli";
  users.users.patrickli.initialHashedPassword = "";
  security.sudo.wheelNeedsPassword = lib.mkForce false;
}
