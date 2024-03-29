# NixOS host configuration

> **Warning**
> This was abandoned in favor of [https://github.com/TLATER/dotfiles](https://github.com/TLATER/dotfiles).
>
> Previously I split the repositories in two, thinking that:
>   1. I would struggle to preserve my dotfiles from before nix
>   2. Splitting would enable me to use home-manager on non-NixOS hosts more easily
>
> Since then I have learned a *lot* about nix and found that:
>   1. Preserving my old dotfiles is trivial
>   2. Flakes mean I do not need to split the repository in two to achieve configuration on non-NixOS
>
> Having the repository split in two also caused no end of headaches
> with `nix flake update`, which I would have to run in both
> repositories separately and somehow still make feed into one
> another. All checks and update scripts also required writing twice.
>
> I would not recommend doing what I did here, but I'll keep it around
> because many people seemed to be interested in the past. Look into
> my dotfiles repository if you'd like to see what I consider good
> practice these days.

This is the collected set of configurations for my various NixOS
hosts.

## Installation

Installing should be as simple as running:

```bash
sudo nixos-rebuild switch --flake 'github:tlater/nixos-hosts#'
```

This will use a clone of this repository to rebuild the local system,
using the hostname to specialize.

The hostname must be one of:

- `yui`
- `ct-lt-02052`

Alternatively, running this from within the cloned repository will
also work, and allow for updates:

```bash
sudo nixos-rebuild switch --flake '.#'
```

## Updating

The repository contains a `flake.lock` file which pins all inputs to
specific versions. To update, run the following command and commit the
update:

```bash
nix flake update
```

This should run once a week automatically in this repository anyway,
so can also be replaced with a rebuild (perhaps after a pull).

To include a custom dotfiles flake location, run like so:

```bash
sudo nixos-rebuild switch\
    --override-input dotfiles /home/tlater/.local/src/dotfiles\
    --no-write-lockfile\
    switch --flake '.#'
```

## Preparing a new system

A new system will not have a hostname registered yet. To prepare a new
system, firstly set up a disk partitioning scheme somewhat like this:

```bash
export ROOT_DISK=/dev/sda

# Create boot partition first
sudo parted -a opt --script "${ROOT_DISK}" \
    mklabel gpt \
    mkpart primary fat32 0% 512MiB \
    mkpart primary 512MiB 100% \
    set 1 esp on \
    name 1 boot \
    set 2 lvm on \
    name 2 root

# Set up boot partition
sudo mkfs.vfat -F32 /dev/disk/by-partlabel/boot

# Set up encrypted volume
sudo cryptsetup --cipher serpent-xts-plain64 --key-size 512 --hash whirlpool luksFormat /dev/disk/by-partlabel/root
sudo cryptsetup luksOpen /dev/disk/by-partlabel/root root

# Set up disk partitions
sudo pvcreate /dev/mapper/root
sudo vgcreate main /dev/mapper/root

sudo lvcreate --size 40G --name nix-store main
sudo lvcreate --size 20G --name root main
sudo lvcreate --size "$(cat /proc/meminfo | grep MemTotal | cut -d':' -f2 | sed 's/ //g')" --name swap main
sudo lvcreate --size 60%FREE --name home main

sudo vgchange --available y

sudo mkfs.ext4 -L nix-store /dev/mapper/main-nix--store
sudo mkfs.ext4 -L root /dev/mapper/main-root
sudo mkswap -L swap /dev/mapper/main-swap
sudo mkfs.ext4 -m 0 -L home /dev/mapper/main-home
```

Then, following the NixOS installation guide, prepare the
auto-configured `hardware-`/`configuration.nix`, and use these to fill
a new host configuration.

The host configuration can then be installed using the following
command, which will also take care of setting the hostname for future
omission if configured correctly:

```bash
sudo nixos-rebuild switch --flake '.#<hostname>'
```
