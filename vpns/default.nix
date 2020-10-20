{ config, pkgs, ... }:

let
  vpns = with pkgs;
    stdenv.mkDerivation {
      pname = "vpns";
      version = "1.0";
      nativeBuildInputs = [ unzip ];
      sourceRoot = ".";
      src = fetchurl {
        url = "https://www.privateinternetaccess.com/openvpn/openvpn.zip";
        sha256 =
          "74ac6ec76cd107e91e8be89d95e186e9c88b842ba80a638d29f23cbfb3d68f0b";
      };
      installPhase = ''
        mkdir -p $out/
        cp c* *.ovpn  $out/
      '';
    };
  make-pia-vpn = config_path: autoStart: {
    config = ''config "${vpns}/${config_path}"'';
    updateResolvConf = true;
    autoStart = autoStart;
    authUserPass = {
      username = config.secrets.pia.user;
      password = config.secrets.pia.password;
    };
  };

in {
  services.openvpn.servers = (builtins.listToAttrs
    (builtins.filter (x: x != null) (map (path:
      let match = builtins.match "(.*)\\.ovpn" path;
      in if match == null then
        null
      else {
        name = builtins.replaceStrings [ " " ] [ "_" ] (builtins.head match);
        value =
          make-pia-vpn path (if match == "Netherlands" then true else false);
      }) (builtins.attrNames (builtins.readDir vpns)))));
}
