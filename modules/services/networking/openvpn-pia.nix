{ config, lib, tlater-pkgs, ... }:

with lib;
let
  cfg = config.services.openvpn.pia-servers;

  # Get a list of valid server names from the configuration files in the package
  servers = (builtins.filter (x: x != null) (map (path:
    let match = builtins.match "(.*)\\.ovpn" path;
    in if match == null then null else builtins.head match) (builtins.attrNames
      (builtins.readDir "${tlater-pkgs.pia-vpn-config}/${pia-dir}"))));

  # Little helper to convert a server name back into a configuration file name
  pia-dir = "share/openvpn/configurations/pia";
  path-from-name = name:
    "${tlater-pkgs.pia-vpn-config}/${pia-dir}/${name}.ovpn";

  # Create an openvpn server configuration from one of our
  # configurations; trivial, but makes the config section easier to
  # write
  make-pia-vpn = name: config: {
    inherit (config) autoStart authUserPass;
    config = ''config "${path-from-name name}"'';
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
          Set the username and password credentials to be used with
          the "auth-user-pass" authentication method.

          WARNING: Using this option will put the credentials WORLD-READABLE in the Nix store!
        '';

        type = types.nullOr (types.submodule {
          options = {
            username = mkOption {
              type = types.str;
              description = "The PIA username to use.";
            };
            password = mkOption {
              type = types.str;
              description = "The password to use.";
            };

          };
        });

      };
    };
  }) servers);

  config = {
    services.openvpn.servers =
      mapAttrs make-pia-vpn (filterAttrs (n: c: c.enable) cfg);
  };
}
