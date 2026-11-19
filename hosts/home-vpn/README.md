# home-vpn: NixOS QCOW2 appliance for Proxmox VE

A minimal headless NixOS VM running a Tailscale **subnet router**, not an
exit node. It advertises the home LAN so external Tailscale clients can
reach LAN devices without installing Tailscale on each LAN device.

- **First provisioning:** boot a prebuilt QCOW2 image in Proxmox.
- **Later upgrades:** use `nixos-rebuild switch --flake .#home-vpn`;
  do not reimport a new image for each release.
- No manual WireGuard keys, SOPS credentials, Docker or GUI.
- Uses NixOS's generic QEMU guest profile, an ext4 root by label, and
  **legacy BIOS/SeaBIOS** GRUB installed for a VirtIO block disk.
- This is a self-contained installation image, not a live ISO.

## Build

From an x86_64-linux Nix build host with virtualization support:

```sh
nix build .#home-vpn-image
ls -lh result/
```

This exposes the standard NixOS `qcow` image variant as
`packages.x86_64-linux.home-vpn-image`, so it can also be built with:

```sh
nixos-rebuild build-image --flake .#home-vpn --image-variant qcow
```

**Before distributing an image**, configure an SSH authorized *public*
key for the `patrickli` user in the host or shared server profile.
The base server module disables SSH passwords and root SSH login. If
you skip this step, you may not be able to access the VM after boot.
Do not bake SSH private keys, Tailscale state, or device identities
into the image.

## Import to PVE

PVE Web UI support for directly importing a QCOW2 depends on your
PVE version and storage settings. If available, use its **Import**
workflow. Otherwise import on the PVE host with `qm disk import`
(or `qm importdisk`); merely uploading a QCOW2 as an ISO is not
sufficient.

Recommended VM hardware:

- **Firmware:** SeaBIOS (this image is BIOS/GRUB, not OVMF/UEFI).
- **CPU/RAM:** 1 vCPU / 1024 MiB.
- **Disk:** import as a **VirtIO Block** drive (`virtio0`) so the guest
  disk is `/dev/vda`, then boot from that disk. Avoid attaching it
  as SCSI unless changing the GRUB disk configuration.
- **Network:** VirtIO NIC bridged to the home LAN (for example,
  `vmbr0`), with DHCP enabled.
- **Start at boot:** enable.

Give the VM a stable LAN address using the router's DHCP reservation
if desired. The virtual disk persists /var/lib/tailscale across
normal NixOS upgrades and reboots. The image has no pre-enrolled
Tailscale node identity.

## Enroll the subnet router

Access the VM through a locally permitted console/SSH path. After
boot:

```sh
sudo tailscale up
sudo tailscale set --advertise-routes=192.168.1.0/24
tailscale status
```

Replace `192.168.1.0/24` with your **actual** LAN CIDR. Open
https://login.tailscale.com/admin/machines and approve the advertised
route. Set tailnet policy to permit the clients that should reach it.
On Linux clients, enable route acceptance using:

```sh
sudo tailscale set --accept-routes=true
```

Tailscale's default subnet-route masquerading makes LAN devices
see this gateway's LAN address, so return routes are typically
unnecessary. It does not forward link-layer discovery such as
broadcast/mDNS. No router UDP port forwarding is needed.

## Update and recover

```sh
sudo nixos-rebuild switch --flake .#home-vpn
```

An update deploys a new NixOS generation to the existing virtual
disk; it does not reinstall the QCOW2. Keep the source checkout
available or deploy from another NixOS build machine. Take a PVE
snapshot before disruptive networking upgrades and use the PVE
console to roll back a failed generation. A newly imported image
will *not* contain the old VM's Tailscale enrollment state.

The QCOW2 is intended for a fresh install only. Never clone a running
or already-enrolled VM's disk to multiple live instances: that can
duplicate machine identities and Tailscale credentials.
