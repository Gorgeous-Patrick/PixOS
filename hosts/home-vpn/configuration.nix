{ ... }:

{
  # Replace the hardware stub with nixos-generate-config output before deploying.
  imports = [
    ./hardware-configuration.nix
    ../base-hosts/server.nix
  ];

  networking.hostName = "home-vpn";
  system.stateVersion = "26.05"; # Match the initial installation release.

  # Subnet-router mode enables IP forwarding. Tailscale handles its own
  # encrypted tunnel, NAT and route management; no additional NAT or
  # WireGuard private-key configuration is needed.
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    openFirewall = true;
  };

  networking.firewall.enable = true;
  # Permits traffic from authenticated tailnet peers to services on this
  # gateway. Tailnet policy still determines which peers can reach the LAN.
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # Announce the actual home LAN using:
  #   sudo tailscale set --advertise-routes=192.168.1.0/24
  # Then approve it in the tailnet admin console. No router port
  # forwarding or public IP is required.
}
