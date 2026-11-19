{ ... }:

{
  # Minimal, headless home LAN gateway. Hardware-specific boot/filesystem
  # settings belong in hardware-configuration.nix (replace the stub after
  # running nixos-generate-config on the actual machine).
  imports = [
    ./hardware-configuration.nix
    ../base-hosts/server.nix
  ];

  networking.hostName = "home-vpn";
  system.stateVersion = "26.05"; # Set to the NixOS version first installed.

  # Prefer a DHCP reservation on your home router for this host.
  # Replace the interface and subnet with your home's actual configuration.
  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.77.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = "/var/lib/wireguard/privatekey";

    # Add one peer per client after generating its public key:
    # peers = [{
    #   publicKey = "<client public key>";
    #   allowedIPs = [ "10.77.0.2/32" ];
    # }];
    peers = [ ];
  };

  # VPN clients can reach the LAN; LAN devices see the VPN gateway's LAN IP.
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking.nat = {
    enable = true;
    externalInterface = "enp1s0"; # Replace with the LAN interface.
    internalInterfaces = [ "wg0" ];
  };

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 51820 ];
    trustedInterfaces = [ "wg0" ];
  };

  # The VPN private key remains local and never enters the Nix store/Git.
  systemd.tmpfiles.rules = [ "d /var/lib/wireguard 0700 root root -" ];
}
