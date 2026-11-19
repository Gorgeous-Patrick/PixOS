# home-vpn: minimal WireGuard LAN gateway

This is a **template**, not a ready-to-boot installation. Replace
`hardware-configuration.nix` with the real machine's generated hardware
configuration and check the bootloader before installing.

- No Tailscale, control plane, GUI, Docker or Home Manager.
- IPv4 split-tunnel VPN: remote peers reach the entire routed home subnet.
- Home LAN sees requests as originating from this gateway's LAN address
  (masquerading); no return routes are needed on the home router.
- LAN discovery protocols such as broadcast/mDNS do **not** automatically
  cross the VPN. Other VLANs or client isolation may require extra routing/rules.

## Set up

1. Install NixOS 26.05 on the target. Generate and copy its real
   `hardware-configuration.nix`; set the correct bootloader.
2. Give this host a stable LAN address (prefer a router DHCP reservation).
3. Edit `configuration.nix`: replace `enp1s0` with the machine's LAN
   interface; adjust the VPN subnet if it conflicts with your LAN.
4. Generate the server key **on the VPN machine**:
   ```sh
   sudo install -d -m 0700 /var/lib/wireguard
   wg genkey | sudo tee /var/lib/wireguard/privatekey >/dev/null
   sudo chmod 0600 /var/lib/wireguard/privatekey
   sudo sh -c 'wg pubkey < /var/lib/wireguard/privatekey'
   ```
   Save only the resulting public key for clients. Never commit private keys.
5. Generate an independent private/public WireGuard keypair on each client.
   Add each client's **public** key to the `peers` list with a unique /32
   tunnel address such as `10.77.0.2/32`.
6. Allow/forward **UDP 51820** on your internet router to the gateway's
   reserved LAN IP. Do not forward TCP 22.
7. Build/apply from your PixOS checkout:
   ```sh
   sudo nixos-rebuild switch --flake .#home-vpn
   ```
   Ensure an authorized SSH public key or working local console before
   switching. The shared server profile disables SSH password login.

## Example external peer configuration

```ini
[Interface]
PrivateKey = CLIENT_PRIVATE_KEY
Address = 10.77.0.2/32

[Peer]
PublicKey = SERVER_PUBLIC_KEY
Endpoint = YOUR_PUBLIC_IP_OR_DDNS:51820
AllowedIPs = 192.168.1.0/24, 10.77.0.0/24
PersistentKeepalive = 25
```

Replace `192.168.1.0/24` with the actual home LAN subnet. Leave
`0.0.0.0/0` **out** of AllowedIPs to keep ordinary internet traffic off
this VPN. For initial testing, disable cellular/Wi-Fi transitions and test
from an external network, not from inside the LAN. Verify with
`sudo wg show` and connections to LAN IPs.

Security note: `trustedInterfaces = [ "wg0" ]` grants authenticated VPN
peers access to services on the gateway; only enroll trusted peers.
