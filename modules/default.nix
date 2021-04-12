{ lib, pkgs, config, ... }:

{
  imports = [
    ./hardware/pulseaudio/echo-canceling.nix
    ./services/networking/openvpn-pia.nix
  ];
}
