{
  description = "tlater's host configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    {
      nixosConfigurations = {
        yui = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            (import ./configurations)
            (import ./configurations/yui)
            (import ./configurations/bluetooth.nix)
            (import ./configurations/wifi.nix)
          ];
          specialArgs = { inherit inputs; };
        };

        ct-lt-02052 = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            (import ./configurations)
            (import ./configurations/ct-lt-02052)
            (import ./configurations/bluetooth.nix)
            (import ./configurations/power.nix)
            (import ./configurations/wifi.nix)

            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t490
          ];
          specialArgs = { inherit inputs; };
        };
      };
    } // (inputs.flake-utils.lib.eachDefaultSystem (system:
      let pkgs = inputs.nixpkgs.legacyPackages.${system};
      in {
        devShell = pkgs.mkShell { buildInputs = with pkgs; [ nixfmt ]; };
      }));
}
