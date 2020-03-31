{ config, pkgs, ... }:

let
  vpns = with pkgs; stdenv.mkDerivation {
    pname = "vpns";
    version = "1.0";
    nativeBuildInputs = [unzip];
    sourceRoot = ".";
    src = fetchurl {
      url = "https://www.privateinternetaccess.com/openvpn/openvpn.zip";
      sha256 = "c1b9abb870a002541237e61bb35f57b1b2db910175b490c2da7679fa1e84b9c5";
    };
    installPhase = ''
      mkdir -p $out/
      cp c* *.ovpn  $out/
    '';
  };

in
{
  services.openvpn.servers = {
    Netherlands = {
      config = "config ${vpns}/Netherlands.ovpn";
      updateResolvConf = true;
      authUserPass = {
        username = config.secrets.pia.user;
        password = config.secrets.pia.password;
      };
    };
  };
}
