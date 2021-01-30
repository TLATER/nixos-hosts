{ stdenv, fetchzip, ... }:

let version = "ZA8RS6eIjMVQfBt+9hYyhaq8LByy5oJaO9Ed+x8KtW8=";

in stdenv.mkDerivation {
  pname = "pia-vpn-config";
  inherit version;

  src = fetchzip {
    url = "https://www.privateinternetaccess.com/openvpn/openvpn.zip";
    sha256 = version;
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/share/openvpn/configurations/pia/
    cp c* *.ovpn $out/share/openvpn/configurations/pia/
  '';

  meta = with stdenv.lib; {
    inherit version;
    description = "Upstream openvpn configurations for PIA";
    homepage = "https://www.privateinternetaccess.com";
    maintainers = [{
      email = "tm@tlater.net";
      github = "tlater";
      githubId = 6654841;
      name = "Tristan Daniël Maat";
    }];
    platforms = platforms.all;
  };
}
