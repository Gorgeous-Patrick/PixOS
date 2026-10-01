{ lib, pkgs, ... }:

{
  time.timeZone = lib.mkDefault "America/Detroit";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  networking.useDHCP = lib.mkDefault true;

  users.users.patrickli = {
    isNormalUser = true;
    description = "Patrick Li";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;
  programs.nix-ld.enable = true;
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  environment.systemPackages = with pkgs; [
    curl
    wget
    rsync
    jq
    unzip
    zip
    btop
    htop
    lsof
    file
    tree
    dnsutils
    openssl
  ];

  pixos.bundles = {
    git.enable = true;
    zsh.enable = true;
  };
}
