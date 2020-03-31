# NixOS host configuration

This is the collected set of configurations for my various NixOS
hosts.

To use, you will need to create a `hardware-configuration.nix` and a
`secrets.nix`, the former preferably automatically during installation
and the latter by hand with knowledge of my secrets.

Otherwise, just drop the files into `/etx/nixos/`. Like so:

    sudo git clone https://github.com/tlater/nixos-hosts /etc/nixos
