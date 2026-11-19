# home-vpn: minimal Tailscale subnet router

This host makes an entire home LAN reachable through Tailscale, without
installing Tailscale on every device. It is a **subnet router**, not an
exit node: ordinary internet browsing continues through each client's
normal connection.

The NixOS host is deliberately minimal: no GUI, Docker, Home Manager,
manual WireGuard keys, SOPS secrets, or router port forwarding.

## Prepare the machine

1. Install NixOS and replace `hardware-configuration.nix` with the
   machine's actual `nixos-generate-config` output. Configure a working
   bootloader; this repository's stub is **not bootable**.
2. Give the host a stable IP on your home LAN, preferably through the
   router's DHCP reservation.
3. Ensure a local console or working SSH authorized public key. The
   shared server profile disables password-based SSH.
4. Set `system.stateVersion` to the initial NixOS installation version
   (the provided value is `26.05`).
5. Apply the host configuration from the PixOS checkout:
   ```sh
   sudo nixos-rebuild switch --flake .#home-vpn
   ```

## Join the tailnet

Run once on the host (interactive device authentication, so no auth
key or SOPS secret is needed):

```sh
sudo tailscale up
```

Open the displayed authentication URL and authorize this machine.
The authenticated state is persisted by tailscaled across reboots.

Then advertise **your actual** home LAN subnet (the following is only
an example):

```sh
sudo tailscale set --advertise-routes=192.168.1.0/24
```

In [Tailscale Machines](https://login.tailscale.com/admin/machines),
find `home-vpn`, open its route settings, and approve the advertised
subnet. Tailnet access-control policies must allow intended clients
to reach the LAN. Consider disabling key expiry for this trusted
always-on subnet router through the Tailscale admin console, after
reviewing the associated security trade-off.

## Clients

Install Tailscale on each external laptop or phone, sign in to the
same tailnet, and enable the VPN connection. Approved subnet routes
are normally accepted automatically on iOS, macOS, and Windows.

On **Linux** clients, explicitly accept routes:

```sh
sudo tailscale set --accept-routes=true
```

Try accessing the home router or another LAN machine by its LAN IP.
Use `tailscale status` and `tailscale ping home-vpn` for diagnostics.

## Scope and limitations

- Tailscale defaults to SNAT/masquerading for subnet-router traffic:
  home devices usually see the gateway's LAN IP and need no static
  return route.
- This is routed IPv4 connectivity, not an Ethernet bridge:
  mDNS/broadcast device discovery may not work across the tunnel.
- All clients need Tailscale; home LAN devices do not.
- No inbound port forwarding is required even if the home internet
  connection has a public IP. NAT traversal will try direct connections;
  relays may be used otherwise.
- Tailscale's hosted coordination service is an intentional dependency.
- The `tailscale0` firewall interface is trusted on this gateway, so
  keep tailnet membership and access-control rules restrictive.
