{ ... }:

{
  networking = {
    hostName = "haruna";

    interfaces = {
      eno1.useDHCP = true;
      enp10s0.useDHCP = true;
      wlp8s0.useDHCP = true;
    };
  };

  # To get nvidia drivers
  nixpkgs.config.allowUnfree = true;

  services = { xserver = { videoDrivers = [ "nvidia" ]; }; };
}
