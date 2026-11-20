{ modulesPath, ... }:

{
  # Generic QEMU/Proxmox virtual hardware: no generated per-VM
  # hardware-configuration.nix is necessary.
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    ../base-hosts/server.nix
  ];

  networking.hostName = "home-vpn";
  networking.useDHCP = true;

  # The qcow image uses an ext4 filesystem labelled "nixos" and BIOS GRUB.
  # Match the virtual disk to PVE's VirtIO block interface (/dev/vda).
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    autoResize = true;
  };
  boot.growPartition = true;
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };
  boot.kernelParams = [ "console=ttyS0" ];

  system.stateVersion = "26.05";

  # Only persistent state is carried forward on routine rebuilds.
  # Configure Tailscale once after first boot and keep /var/lib/tailscale
  # on the VM's persistent root disk.
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    openFirewall = true;
  };
  networking.firewall.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # Each VM needs a unique SSH host key and Tailscale identity.
  # Never create reusable golden images from an already-enrolled VM.
}
