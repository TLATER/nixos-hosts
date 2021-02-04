{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.initrd = {
    availableKernelModules = [ "hid_roccat_ryos" ];

    luks.devices.root.device =
      "/dev/disk/by-uuid/b3ac7dc6-cb0b-4350-bdfb-32329a5f61ff";
  };

  networking = {
    hostName = "ct-lt-02052";
    interfaces = {
      enp0s31f6.useDHCP = true;
      wlp0s20f3.useDHCP = true;
    };
  };

  environment.systemPackages = with pkgs; [
    docker-compose # Better to keep it in lock-step with the system docker
    fuse3 # For bst and related things
  ];

  # Virtualization is a lot more common at work...
  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };
  users.users.tlater.extraGroups = [ "docker" "libvirtd" ];

  hardware.cpu.intel.updateMicrocode = true;
  security.pki.certificates = [ (builtins.readFile ./codethink-wifi.cert) ];
}
