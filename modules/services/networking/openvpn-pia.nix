{ config, lib, tlater-pkgs, ... }:

with lib;
let
  cfg = config.services.openvpn.pia-servers;

  # Get a list of valid server names from the configuration files in the package
  servers = (builtins.filter (x: x != null) (map (path:
    let match = builtins.match "(.*)\\.ovpn" path;
    in if match == null then null else builtins.head match) (builtins.attrNames
      (builtins.readDir "${pkgs.tlater.pia-vpn-config}/${pia-dir}"))));

  # Little helper to convert a server name back into a configuration file name
  pia-dir = "share/openvpn/configurations/pia";
  path-from-name = name:
    "${pkgs.tlater.pia-vpn-config}/${pia-dir}/${name}.ovpn";

  # Create an openvpn server configuration from one of our
  # configurations; trivial, but makes the config section easier to
  # write
  make-pia-vpn = name: config: {
    inherit (config) autoStart;
    config = ''
      config "${path-from-name name}"
      auth-user-pass ${config.authUserPass}
    '';
    updateResolvConf = true;
  };

in {
  options.services.openvpn.pia-servers = listToAttrs (map (server: {
    name = server;
    value = {
      enable = mkEnableOption {
        default = false;
        description =
          "Enable the OpenVPN configuration for PIA's netherlands server.";
      };

      autoStart = mkOption {
        type = types.bool;
        default = false;
        description =
          "Whether this OpenVPN instance should be automatically started.";
      };

      authUserPass = mkOption {
        default = null;
        description = ''
          Set a file from which to read the username/password for the connection.
        '';
        type = types.nullOr types.path;
      };
    };
  }) servers);

  config = {
    services.openvpn.servers =
      mapAttrs make-pia-vpn (filterAttrs (n: c: c.enable) cfg);
  };
}
