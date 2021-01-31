{
  description = "tlater's host configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    flake-utils.url = "github:numtide/flake-utils";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    let
      # A helper function that removes the duplication of things that
      # will be common across all hosts.
      make-nixos-system = { nixpkgs, system, modules ? [ ] }:
        let pkgs = nixpkgs.legacyPackages.${system};
        in nixpkgs.lib.nixosSystem {
          inherit system;
          modules =
            [ (import ./configurations) inputs.sops-nix.nixosModules.sops ]
            ++ modules;
          extraModules = [ (import ./modules) ];
          specialArgs = {
            inherit inputs;
            tlater-pkgs = (import ./pkgs { inherit pkgs; });
          };
        };

    in {
      nixosConfigurations = {
        yui = make-nixos-system {
          nixpkgs = inputs.nixpkgs;
          system = "x86_64-linux";
          modules = [
            (import ./configurations/yui)
            (import ./configurations/bluetooth.nix)
            (import ./configurations/wifi.nix)
          ];
        };

        ct-lt-02052 = make-nixos-system {
          nixpkgs = inputs.nixpkgs;
          system = "x86_64-linux";
          modules = [
            (import ./configurations/ct-lt-02052)
            (import ./configurations/bluetooth.nix)
            (import ./configurations/power.nix)
            (import ./configurations/wifi.nix)

            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t490
          ];
        };
      };
    }
    # Set up a "dev shell" that will work on all architectures.
    // (inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        sops-pkgs = inputs.sops-nix.packages.${system};
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; with sops-pkgs; [ nixfmt sops-init-gpg-key ];
          nativeBuildInputs = with sops-pkgs; [ sops-pgp-hook ];
          sopsPGPKeyDirs = [ "./keys/hosts/" "./keys/users/" ];
        };
      }));
}
