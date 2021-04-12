{ lib, pkgs, config, ... }:

{
  imports = [
    ./hardware/pulseaudio/echo-canceling.nix
    ./hardware/pulseaudio/rnnoise-suppression.nix
    ./services/networking/openvpn-pia.nix
  ];
}
