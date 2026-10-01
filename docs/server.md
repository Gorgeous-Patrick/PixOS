# PixOS server ISO

Build on an x86_64 Linux machine (or with an x86_64 Linux remote builder):

```sh
nix build path:.#server-iso
ls result/iso/
```

The ISO supports BIOS and UEFI boot and includes the PixOS Zsh and Neovim
bundles, Git/lazygit, Zellij, fzf, zoxide, yazi, btop/htop, curl, rsync, and jq. The existing Neovim bundle includes language
servers and plugins, so this is not a tiny rescue image. `path:.` also includes
new files before they have been staged in Git.

The live console logs in as `patrickli` with passwordless sudo. SSH accepts keys
only; add your public key to `users.users.patrickli.openssh.authorizedKeys.keys`
in `hosts/iso-server/configuration.nix` before building for remote login.
The live-console policy belongs only to the ISO, not the reusable server module.

## Persistence and installation

A live ISO uses a writable temporary overlay: files and SSH host keys are lost
on reboot unless you configure persistent storage. The ISO does not partition
or erase disks automatically.

For a permanent installation, import `pixos.nixosModules.server` into the target
machine's `nixosSystem`, alongside its generated hardware configuration. Set its
bootloader, hostname, authorized SSH keys, login/password configuration for sudo,
and `system.stateVersion`. Follow the server's installed NixOS release for the
initial state version; retain it on upgrades. Use the same Nixpkgs and Home Manager
inputs as PixOS. The reusable module includes Home Manager and the PixOS overlays.
