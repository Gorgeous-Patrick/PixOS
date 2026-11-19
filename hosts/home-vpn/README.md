# home-vpn: minimal WireGuard gateway with isolated sops-nix secret

This host uses native WireGuard, IPv4 forwarding and NAT to reach the home
LAN from outside. It does **not** use Tailscale, Docker, a GUI or Home Manager.

**Not yet deployable:** replace the hardware-configuration stub, populate
the dedicated encrypted `secrets/home-vpn.yaml`, and update the physical
network interface and peer list before building.

## Age identity: generate on home-vpn

From a NixOS live installer or the installed host, install `age` temporarily
if needed (`nix shell nixpkgs#age`). Run:

```sh
sudo install -d -m 0700 /var/lib/sops-nix
sudo sh -c 'umask 077; age-keygen -o /var/lib/sops-nix/key.txt'
sudo chmod 0600 /var/lib/sops-nix/key.txt
sudo age-keygen -y /var/lib/sops-nix/key.txt
```

The **last command prints the public recipient** (`age1...`).
Store `/var/lib/sops-nix/key.txt` securely and never commit it or paste
it into an issue/PR. Preserve it across reinstallations or re-encrypt
the secret for a replacement identity.

In the repository's `.sops.yaml`:
1. Replace the commented `&home_vpn age1...` placeholder with that public
   recipient, removing the leading `#`.
2. Uncomment `- *home_vpn` **only** under the exact
   `secrets/home-vpn.yaml` rule.
3. Never add `*home_vpn` to the generic `secrets/.*` rule.

The current rules also grant the framework, macOS, and offline backup
identities decryption access for recovery/administration. The **home-vpn
identity itself** will only decrypt `secrets/home-vpn.yaml`; this is
recipient-level isolation, not a restriction on an administrator who
controls the machine or another authorized age identity.

## Generate and encrypt WireGuard server key

Run on a trusted machine with SOPS installed and an authorized age
identity that is a recipient for `secrets/home-vpn.yaml` (e.g. your
framework/macOS host). After updating `.sops.yaml`:

```sh
umask 077
wg genkey > /tmp/home-vpn-wg-private
printf 'wireguard_private_key: %s\n' "$(cat /tmp/home-vpn-wg-private)" > /tmp/home-vpn-plaintext.yaml
sops --encrypt --config .sops.yaml \
  --filename-override secrets/home-vpn.yaml \
  /tmp/home-vpn-plaintext.yaml > secrets/home-vpn.yaml
wg pubkey < /tmp/home-vpn-wg-private
rm -f /tmp/home-vpn-wg-private /tmp/home-vpn-plaintext.yaml
```

The output of `wg pubkey` is the **server public key** to put on the
clients. Never commit either plaintext file; encrypted
`secrets/home-vpn.yaml` is intended for Git. Because plaintext is
temporarily written to disk in the example, prefer a temporary
RAM-backed directory (e.g. `/dev/shm`) on trusted machines and ensure
no plaintext backups exist. You may use `sops secrets/home-vpn.yaml`
to create the YAML interactively instead, avoiding plaintext files.

Note: an age identity and a WireGuard private key are **different keys**.
The age key only decrypts the WireGuard key at boot via sops-nix.

## Network, peers, and deploy

1. Install NixOS 26.05 and replace `hardware-configuration.nix` with
   the real generated configuration and bootloader settings.
2. Reserve this host's LAN address in the home router. Update
   `externalInterface = "enp1s0"` with its actual LAN interface.
3. Add a WireGuard `peers` entry per external device, using each
   client's public key and unique tunnel IP, e.g.:
   ```nix
   peers = [{
     publicKey = "CLIENT_PUBLIC_KEY";
     allowedIPs = [ "10.77.0.2/32" ];
   }];
   ```
4. Forward **UDP 51820** on the router to the VPN host's reserved IP.
   Do not forward SSH (TCP 22).
5. Ensure the home-vpn machine already has its age private key at
   `/var/lib/sops-nix/key.txt` and that the encrypted YAML exists in Git.
   Provide an authorized SSH key or local console: the shared server
   profile disables password-based SSH.
6. Build/apply:
   ```sh
   sudo nixos-rebuild switch --flake .#home-vpn
   sudo wg show
   ```

Example client profile (replace all placeholders and the actual LAN subnet):

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

This is a split tunnel: ordinary internet traffic stays outside the VPN.
NAT makes the home devices see the gateway's LAN IP. Broadcast/mDNS
discovery may not work across the tunnel. The trusted `wg0` interface
allows authenticated peers access to host services, so enroll only
trusted devices.
