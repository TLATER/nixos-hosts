{ lib, pkgs, config, ... }:

{
  imports = [ ./services/networking/openvpn-pia.nix ];
}
