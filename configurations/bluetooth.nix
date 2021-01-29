{ pkgs, ... }:

{
  hardware = {
    pulseaudio = {
      package = pkgs.pulseaudioFull;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
    };
    bluetooth.enable = true;
  };
}
