{ pkgs, lib, inputs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    kernelPackages = lib.mkOverride 99 pkgs.unstable.linuxPackages_latest;

    initrd = {
      availableKernelModules = [ "hid_roccat_ryos" ];
      luks.devices = {
        root.device = "/dev/disk/by-uuid/3c0d48f6-f051-4328-9919-677a7fcddae7";
        storage = {
          allowDiscards = true;
          device = "/dev/disk/by-uuid/dd17e735-fac4-467f-b1ee-8bb214bc2b08";
        };
      };
    };
  };

  networking = {
    hostName = "yui";
    interfaces = {
      eno1.useDHCP = true;
      wlp7s0.useDHCP = true;
    };

    # Allow barrier
    firewall.allowedTCPPorts = [ 24800 ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    pulseaudio = {
      rnnoise-suppression = {
        enable = true;
        source =
          "alsa_input.usb-Blue_Microphones_Blue_Snowball_2029BAA0FBM8-00.analog-stereo";
        suppression-type = "stereo";
        voice-threshold = 60;
      };
    };

    cpu.amd.updateMicrocode = true;
  };

  sops.secrets.pia = { };
  services.openvpn.pia-servers.netherlands = {
    enable = true;
    autoStart = true;
    authUserPass = "/run/secrets/pia";
  };
}
