{ config, ... }:

{
  # Replace the hardware stub with nixos-generate-config output before deploying.
  imports = [
    ./hardware-configuration.nix
    ../base-hosts/server.nix
  ];

  networking.hostName = "home-vpn";
  system.stateVersion = "26.05"; # Match the initial installation release.

  # The home-vpn host receives a dedicated age identity. Its public
  # recipient must NOT be included in any other secrets' recipient sets.
  sops = {
    defaultSopsFile = ../../secrets/home-vpn.yaml;
    defaultSopsFormat = "yaml";
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = false;
      sshKeyPaths = [ ];
    };
    secrets.wireguard_private_key = {
      owner = "root";
      mode = "0400";
      restartUnits = [ "wg-quick-wg0.service" ];
    };
  };

  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.77.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = config.sops.secrets.wireguard_private_key.path;

    # Add each client with its public key and unique /32 tunnel address.
    peers = [ ];
  };

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking.nat = {
    enable = true;
    externalInterface = "enp1s0"; # Replace with actual LAN interface.
    internalInterfaces = [ "wg0" ];
  };

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 51820 ];
    trustedInterfaces = [ "wg0" ];
  };
}
