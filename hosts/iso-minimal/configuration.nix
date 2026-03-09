{
  config,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.patrickli = {
    isNormalUser = true;
    description = "PatrickLi";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [ ];
  };

  programs.zsh.enable = true;

  pixos.bundles.zsh.enable = true;
}
