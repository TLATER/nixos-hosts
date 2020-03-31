{ lib, ... }:

with lib;
with types;

{
  options = {
    secrets.pia = {
      user = mkOption { type = str; };
      password = mkOption { type = str; };
    };
  };
}
