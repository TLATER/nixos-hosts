{ pkgs, lib, inputs, ... }:

let
  allow-nvidia = pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
      "nvidia-persistenced"
    ];
  overlay-unstable = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = prev.system;
      config.allowUnfreePredicate = allow-nvidia;
    };
  };

in {
  nixpkgs.overlays = [ overlay-unstable ];

  imports = [ ./hardware-configuration.nix ];

  boot = {
    kernelPackages = lib.mkOverride 99 pkgs.unstable.linuxPackages_5_10;

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
  };

  nixpkgs.config.allowUnfreePredicate = allow-nvidia;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.cpu.amd.updateMicrocode = true;
}
