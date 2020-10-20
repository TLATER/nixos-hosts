{ config, pkgs, ... }:

let
  vpns = with pkgs; stdenv.mkDerivation {
    pname = "vpns";
    version = "1.0";
    nativeBuildInputs = [unzip];
    sourceRoot = ".";
    src = fetchurl {
      url = "https://www.privateinternetaccess.com/openvpn/openvpn.zip";
      sha256 = "74ac6ec76cd107e91e8be89d95e186e9c88b842ba80a638d29f23cbfb3d68f0b";
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
